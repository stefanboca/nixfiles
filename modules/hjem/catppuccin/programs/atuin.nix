{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (lib.modules) mkIf;

  source = config.catppuccin.sources.atuin;
  themeName = "catppuccin-${cfg.flavor}-${cfg.accent}";

  cfg = config.catppuccin.programs.atuin;
in {
  options.catppuccin.programs.atuin = mkCatppuccinOption {
    name = "atuin";
    accentSupport = true;
  };

  config = mkIf (cfg.enable && config.rum.programs.atuin.enable) {
    rum.programs.atuin = {
      settings.theme.name = themeName;
    };

    xdg.config.files = {
      "atuin/themes/${themeName}.toml".source = "${source}/${cfg.flavor}/${themeName}.toml";
    };
  };
}
