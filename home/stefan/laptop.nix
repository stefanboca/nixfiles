{
  config,
  lib,
  pkgs,
  ...
}:

let
  # override pkgs with cuda support, in order to get cache hits
  pkgs-cuda = import pkgs.path {
    inherit (pkgs) system overlays;
    config = pkgs.config // {
      cudaSupport = true;
    };
  };
in
{
  imports = [
    ./shared.nix
    ./sops.nix
  ];

  desktop = {
    enable = true;
    wm.enableNiri = true;
  };

  home.packages = with pkgs; [
    esphome
    pkgs-cuda.blender
    # calibre
    freecad
    geogebra6
    # musescore
    prusa-slicer
    rnote
    # xournalpp
    # zotero
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/prusaslicer" = "PrusaSlicer.desktop";
  };

  theming.niri.outputs = [
    "DP-1"
    "eDP-1"
  ];

  programs = {
    obs-studio.enable = true;
    aerc.enable = true;

    niri.settings = {
      input.tablet.map-to-output = "eDP-1";
      input.touch.map-to-output = "eDP-1";
      binds = with config.lib.niri.actions; {
        XF86MonBrightnessUp = lib.mkForce {
          allow-when-locked = true;
          action = spawn [
            "sh"
            "-c"
            "brightnessctl -d intel_backlight set +10%; brightnessctl -d asus_screenpad set +10%"
          ];
        };
        XF86MonBrightnessDown = lib.mkForce {
          allow-when-locked = true;
          action = spawn [
            "sh"
            "-c"
            "brightnessctl -d intel_backlight set 10%-; brightnessctl -d asus_screenpad set 10%-"
          ];
        };
        XF86DisplayToggle.action = spawn [ "toggle-screenpad-backlight" ];
        "Mod+XF86Launch2".action = focus-monitor-next;
        "Mod+Shift+XF86Launch2".action = move-window-to-monitor-next;
        "Mod+Ctrl+XF86Launch2".action = move-workspace-to-monitor-next;
        "XF86Launch2".action = focus-monitor-previous;
        "Shift+XF86Launch2".action = move-window-to-monitor-previous;
        "Ctrl+XF86Launch2".action = move-workspace-to-monitor-previous;
      };

      outputs = rec {
        eDP-1 = {
          mode = {
            width = 2800;
            height = 1800;
            refresh = 120.016;
          };
          scale = 1.25;
          focus-at-startup = true;
          position = {
            x = 0;
            y = 0;
          };
        };
        DP-1 = {
          mode = {
            width = 2880;
            height = 864;
            refresh = 60.008;
          };
          scale = 1.25;
          position = {
            x = 0;
            y = builtins.ceil (eDP-1.mode.height / eDP-1.scale);
          };
        };
      };

      # NOTE: this fixes the main display turning off when re-opening the lid
      # debug.keep-laptop-panel-on-when-lid-is-closed = [ ];
    };
  };

  dconf = {
    enable = true;
    settings = {
      # map screenpad touchscreen to correct display
      "org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = [
        "BOE"
        "0x0a8d"
        "0x00000000"
      ];
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/mutter".experimental-features = [
        "autoclose-xwayland"
        "kms-modifiers"
        "scale-monitor-framebuffer"
        "variable-refresh-rate"
        "xwayland-native-scaling"
      ];
    };
  };
}
