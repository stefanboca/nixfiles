# customize limine module to avoid IFD
{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep substring;

  isDark = cfg.flavor != "latte";
  palette = mapAttrs (_: color: substring 1 6 color.hex) config.catppuccin.palette.${cfg.flavor}.colors;

  cfg = config.catppuccin.limine;
in {
  options.catppuccin.limine = mkCatppuccinOption {name = "limine";};

  config.boot.loader.limine.style = mkIf cfg.enable {
    wallpapers = [];
    graphicalTerminal = {
      background = palette.base;
      foreground = palette.text;
      brightBackground =
        if isDark
        then palette.surface2
        else palette.surface0;
      brightForeground = palette.text;

      palette = concatStringsSep ";" [palette.base palette.red palette.green palette.yellow palette.blue palette.pink palette.teal palette.text];
      brightPalette = concatStringsSep ";" [
        (
          if isDark
          then palette.surface2
          else palette.subtext0
        )
        palette.red
        palette.green
        palette.yellow
        palette.blue
        palette.pink
        palette.teal
        palette.text
      ];
    };
  };
}
