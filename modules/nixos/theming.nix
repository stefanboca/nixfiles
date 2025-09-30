{
  config,
  lib,
  ...
}: let
  cfg = config.theming;
in {
  imports = [../common/theming.nix];

  config = lib.mkIf cfg.enable {
    catppuccin = {
      sddm = {
        font = cfg.fonts.sansSerif.name;
        fontSize = builtins.toString cfg.fonts.sizes.desktop;
      };
    };

    environment.systemPackages = cfg.fontPackages;

    console = {
      font = cfg.fonts.monospace.name;
      packages = [cfg.fonts.monospace.package];
    };
  };
}
