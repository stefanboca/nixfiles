{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) importApply mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) submoduleWith;

  spicetify = inputs.spicetify-nix;

  cfg = config.rum.programs.spicetify;
in {
  options.rum.programs.spicetify = mkOption {
    type = submoduleWith {
      specialArgs = {inherit pkgs;};
      modules = [
        (importApply (spicetify + "modules/options.nix") spicetify)
        (spicetify + "modules/linuxOpts.nix")
      ];
    };
    default = {};
  };

  config = mkIf cfg.enable {
    packages = cfg.createdPackages;

    warnings = map (warning: "rum.programs.spicetify: ${warning}") cfg.warnings;
    assertions =
      map (assertion: {
        inherit (assertion) assertion;
        message = "rum.programs.spicetify: ${assertion.message}";
      })
      cfg.assertions;
  };
}
