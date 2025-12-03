{
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  # override pkgs with cuda support, in order to get cache hits
  pkgs-cuda = import pkgs.path {
    inherit (pkgs) overlays;
    inherit (pkgs.stdenv.hostPlatform) system;
    config = pkgs.config // {cudaSupport = true;};
  };
in {
  imports = [
    ./shared.nix
    ./sops.nix

    "${modulesPath}/programs/aerc"
    "${modulesPath}/programs/obs-studio.nix"
  ];

  home.packages = with pkgs; [
    esphome
    pkgs-cuda.blender
    calibre
    fluent-reader
    freecad
    geogebra6
    libreoffice
    # musescore
    prusa-slicer
    rnote
    # xournalpp
    # zotero
  ];

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
      binds = {
        "XF86MonBrightnessUp" = lib.mkForce {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "brightness" "increment" "5" "backlight:intel_backlight"];
        };
        "XF86MonBrightnessDown" = lib.mkForce {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "brightness" "decrement" "5" "backlight:intel_backlight"];
        };
        "Shift+XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "brightness" "increment" "5" "backlight:asus_screenpad"];
        };
        "Shift+XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "brightness" "decrement" "5" "backlight:asus_screenpad"];
        };
        "XF86DisplayToggle" = {
          allow-when-locked = true;
          action.spawn = ["toggle-screenpad-backlight"];
        };
        "XF86Launch1" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "mpris" "playPause"];
        };
        "Mod+XF86Launch2".action.focus-monitor-next = {};
        "Mod+Shift+XF86Launch2".action.move-window-to-monitor-next = {};
        "Mod+Ctrl+XF86Launch2".action.move-workspace-to-monitor-next = {};
        "XF86Launch2".action.focus-monitor-previous = {};
        "Shift+XF86Launch2".action.move-window-to-monitor-previous = {};
        "Ctrl+XF86Launch2".action.move-workspace-to-monitor-previous = {};
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

      # ignore/don't open NVIDIA gpu
      debug.ignore-drm-device = "/dev/dri/renderD129";

      # NOTE: this fixes the main display turning off when re-opening the lid
      # debug.keep-laptop-panel-on-when-lid-is-closed = [ ];
    };
  };

  dconf = {
    enable = true;
    # map screenpad touchscreen to correct display in gnome
    settings."org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = ["BOE" "0x0a8d" "0x00000000"];
  };
}
