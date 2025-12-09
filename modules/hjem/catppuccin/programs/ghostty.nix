{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;

  source = config.catppuccin.sources.ghostty;
  themeName = "catppuccin-${cfg.flavor}";

  cfg = config.catppuccin.programs.ghostty;
in {
  options.catppuccin.programs.ghostty = mkCatppuccinOption {name = "ghostty";};

  config = lib.mkIf (cfg.enable && config.rum.programs.ghostty.enable) {
    xdg.config.files."ghostty/themes/${themeName}".source = "${source}/${themeName}.conf";

    rum.programs.ghostty.settings = {
      theme = "light:${themeName},dark:${themeName}";
    };
  };
}
