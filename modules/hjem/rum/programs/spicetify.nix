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

  cfg = config.rum.programs.spicetify;
in {
  options.rum.programs.spicetify = mkOption {
    type = submoduleWith {
      specialArgs = {inherit pkgs;};
      modules = [
        (importApply (inputs.spicetify-nix + "/modules/options.nix") {packages = pkgs.spicePkgs;})
        (inputs.spicetify-nix + "/modules/linuxOpts.nix")
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
