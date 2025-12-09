# customize tty module to avoid IFD
{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) substring;

  inherit (config.catppuccin) palette;

  cfg = config.catppuccin.tty;
in {
  options.catppuccin.tty = mkCatppuccinOption {name = "tty";};

  config = mkIf (cfg.enable && config.console.enable) {
    # Manually populate with colors from catppuccin/tty
    # Make sure to strip initial # from hex codes
    console.colors = map (color: (substring 1 6 palette.${color}.hex)) [
      "base"
      "red"
      "green"
      "yellow"
      "blue"
      "pink"
      "teal"
      "subtext1"

      "surface2"
      "red"
      "green"
      "yellow"
      "blue"
      "pink"
      "teal"
      "subtext0"
    ];
  };
}
