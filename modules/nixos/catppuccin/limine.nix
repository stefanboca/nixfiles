{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;

  isDark = cfg.flavor != "latte";
  palette = config.catppuccin.palette.${cfg.flavor}.colors;

  cfg = config.catppuccin.limine;
in {
  options.catppuccin.limine = mkCatppuccinOption {name = "limine";};

  config.boot.loader.limine.style = mkIf cfg.enable {
    wallpapers = [];
    graphicalTerminal = {
      background = palette.base.hex;
      foreground = palette.text.hex;
      brightBackground =
        if isDark
        then palette.surface2.hex
        else palette.surface0.hex;
      brightForeground = palette.text.hex;

      palette = concatStringsSep ";" [palette.base.hex palette.red.hex palette.green.hex palette.yellow.hex palette.blue.hex palette.pink.hex palette.teal.hex palette.text.hex];
      brightPalette = concatStringsSep ";" [
        (
          if isDark
          then palette.surface2.hex
          else palette.subtext0.hex
        )
        palette.red.hex
        palette.green.hex
        palette.yellow.hex
        palette.blue.hex
        palette.pink.hex
        palette.teal.hex
        palette.text.hex
      ];
    };
  };
}
