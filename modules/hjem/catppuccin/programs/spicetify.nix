{catppuccinLib}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (lib.modules) mkIf;

  cfg = config.catppuccin.programs.spicetify;
in {
  options.catppuccin.programs.spicetify = mkCatppuccinOption {
    name = "atuin";
    # disabled due to an infinite recursion error when using mkIf (cfg.enable && config.rum.programs.spicetify.enable)
    useGlobalEnable = false;
  };

  config = mkIf cfg.enable {
    rum.programs.spicetify = {
      theme = pkgs.spicePkgs.themes.catppuccin;
      colorScheme = config.catppuccin.flavor;
    };
  };
}
