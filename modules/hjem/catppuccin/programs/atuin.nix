{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (config.catppuccin) sources;
  inherit (lib.modules) mkIf;

  themeName = "catppuccin-${cfg.flavor}-${cfg.accent}";

  cfg = config.catppuccin.programs.atuin;
in {
  options.catppuccin.programs.atuin = catppuccinLib.mkCatppuccinOption {
    name = "atuin";
    accentSupport = true;
  };

  config = mkIf (cfg.enable && config.rum.programs.atuin.enable) {
    rum.programs.atuin = {
      settings.theme.name = themeName;
    };

    xdg.config.files = {
      "atuin/themes/${themeName}.toml".source = "${sources.atuin}/${cfg.flavor}/${themeName}.toml";
    };
  };
}
