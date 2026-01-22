{catppuccinLib}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (config.catppuccin) accent;
  inherit (lib.modules) mkBefore mkIf;

  palette = config.catppuccin.palette.${cfg.flavor}.colors;

  niriConfigFile =
    pkgs.writeText "niri-catppucin.kdl"
    # kdl
    ''
      overview {
        backdrop-color "${palette.crust.hex}"
      }

      layout {
        background-color "${palette.mantle.hex}"

        shadow {
          color "${palette.crust.hex}"
          inactive-color "${palette.crust.hex}"
        }
      }

      recent-windows {
        highlight {
          active-color "${palette.${accent}.hex}"
          urgent-color "${palette.red.hex}"
        }
      }
    '';

  cfg = config.catppuccin.desktops.niri;
in {
  options.catppuccin.desktops.niri = mkCatppuccinOption {name = "niri";};

  config = mkIf (cfg.enable && config.rum.desktops.niri.enable) {
    rum.desktops.niri.config =
      mkBefore
      # kdl
      ''
        include "${niriConfigFile}"
      '';
  };
}
