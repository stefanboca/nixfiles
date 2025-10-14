{
  config,
  lib,
  ...
}: let
  cfg = config.desktop.wm;
in {
  options.desktop.wm.enableNiri = lib.mkEnableOption "niri WM";

  config = lib.mkIf cfg.enableNiri {
    programs.niri.settings = {
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
      hotkey-overlay.skip-at-startup = true;
      xwayland-satellite.path = "xwayland-satellite";
      cursor = {
        hide-when-typing = true;
        hide-after-inactive-ms = 10000;
      };
      config-notification.disable-failed = true; # handled by dms
      spawn-at-startup = [{command = ["wl-paste" "--watch" "cliphist" "store"];}];

      input = {
        keyboard = {
          xkb = {
            layout = "us";
            options = "caps:ctrl_modifier";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
          click-method = "clickfinger";
        };

        warp-mouse-to-focus.enable = true;
      };

      layout = {
        gaps = 8;
        center-focused-column = "on-overflow";
        always-center-single-column = true;
        empty-workspace-above-first = true;
        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
        ];
        default-column-width = {
          proportion = 0.5;
        };

        focus-ring = {
          width = 2;
        };
        shadow = {
          enable = true;
        };
      };

      window-rules = [
        {
          geometry-corner-radius = {
            bottom-left = 10.0;
            bottom-right = 10.0;
            top-left = 10.0;
            top-right = 10.0;
          };
          clip-to-geometry = true;
        }
        {
          matches = [
            {
              app-id = "^firefox";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
      ];

      binds = with config.lib.niri.actions; let
        dms-ipc = spawn "dms" "ipc";
      in {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+T" = {
          hotkey-overlay.title = "Open Ghostty";
          action = spawn "ghostty" "--gtk-single-instance=true";
        };
        "Mod+B" = {
          hotkey-overlay.title = "Open Browser";
          action = spawn "firefox-nightly";
        };
        "Mod+Space" = {
          hotkey-overlay.title = "Application Launcher";
          action = dms-ipc "spotlight" "toggle";
        };
        "Mod+Ctrl+B" = {
          hotkey-overlay.title = "Toggle DMS Bar";
          action = dms-ipc "bar" "toggle";
        };
        "Mod+Ctrl+N" = {
          hotkey-overlay.title = "Toggle DMS Notepad";
          action = dms-ipc "notepad" "toggle";
        };
        "Mod+X" = {
          hotkey-overlay.title = "Toggle DMS Power Menu";
          action = dms-ipc "powermenu" "toggle";
        };
        "Super+Alt+L" = {
          hotkey-overlay.title = "Lock";
          action = dms-ipc "lock" "lock";
        };
        "Mod+Ctrl+Shift+R" = {
          allow-when-locked = true;
          hotkey-overlay.title = "Restart DMS";
          action = spawn "dms" "restart";
        };

        XF86AudioRaiseVolume = {
          allow-when-locked = true;
          action = dms-ipc "audio" "increment" "3";
        };
        XF86AudioLowerVolume = {
          allow-when-locked = true;
          action = dms-ipc "audio" "decrement" "3";
        };
        XF86AudioPlay = {
          allow-when-locked = true;
          action = dms-ipc "mpris" "playPause";
        };
        XF86AudioStop = {
          allow-when-locked = true;
          action = dms-ipc "mpris" "stop";
        };
        XF86AudioNext = {
          allow-when-locked = true;
          action = dms-ipc "mpris" "next";
        };
        XF86AudioPrev = {
          allow-when-locked = true;
          action = dms-ipc "mpris" "previous";
        };
        XF86AudioMute = {
          allow-when-locked = true;
          action = dms-ipc "audio" "mute";
        };
        XF86AudioMicMute = {
          allow-when-locked = true;
          action = dms-ipc "audio" "micmute";
        };

        XF86MonBrightnessUp = {
          allow-when-locked = true;
          action = dms-ipc "brightnessctl" "increment" "5";
        };
        XF86MonBrightnessDown = {
          allow-when-locked = true;
          action = dms-ipc "brightnessctl" "decrement" "5";
        };

        "Mod+O" = {
          repeat = false;
          action = toggle-overview;
        };

        "Mod+Q" = {
          repeat = false;
          action = close-window;
        };

        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;

        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+L".action = move-column-right;

        "Mod+Ctrl+H".action = focus-monitor-left;
        "Mod+Ctrl+J".action = focus-monitor-down;
        "Mod+Ctrl+K".action = focus-monitor-up;
        "Mod+Ctrl+L".action = focus-monitor-right;

        "Mod+Shift+Ctrl+H".action = move-window-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-window-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-window-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-window-to-monitor-right;

        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+Shift+U".action = move-window-to-workspace-down;
        "Mod+Shift+I".action = move-window-to-workspace-up;
        "Mod+Ctrl+U".action = move-workspace-down;
        "Mod+Ctrl+I".action = move-workspace-up;
        "Mod+Ctrl+Shift+U".action = move-workspace-to-monitor-down;
        "Mod+Ctrl+Shift+I".action = move-workspace-to-monitor-up;

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        "Mod+Shift+1".action.move-window-to-workspace = 1;
        "Mod+Shift+2".action.move-window-to-workspace = 2;
        "Mod+Shift+3".action.move-window-to-workspace = 3;
        "Mod+Shift+4".action.move-window-to-workspace = 4;
        "Mod+Shift+5".action.move-window-to-workspace = 5;
        "Mod+Shift+6".action.move-window-to-workspace = 6;
        "Mod+Shift+7".action.move-window-to-workspace = 7;
        "Mod+Shift+8".action.move-window-to-workspace = 8;
        "Mod+Shift+9".action.move-window-to-workspace = 9;

        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;

        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = expand-column-to-available-width;

        "Mod+C".action = center-column;
        "Mod+Ctrl+C".action = center-visible-columns;

        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";

        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        "Mod+W".action = toggle-column-tabbed-display;

        "XF86SelectiveScreenshot".action.screenshot = {};
        "Print".action.screenshot = {};
        "Shift+Print".action.screenshot-window = {};
        "Ctrl+Print".action.screenshot-screen = {};

        "Mod+Escape" = {
          allow-inhibiting = false;
          action = toggle-keyboard-shortcuts-inhibit;
        };

        "Mod+Shift+P".action = power-off-monitors;

        "Mod+Shift+E".action = quit;
        "Ctrl+Alt+Delete".action = quit;
      };
    };

    xdg = {
      userDirs = {
        enable = true;
        desktop = null;
        publicShare = null;
        templates = null;
      };
      mimeApps = {
        associations.added = {
          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        };
        defaultApplications = {
          "application/pdf" = "org.gnome.Evince.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          "image/svg+xml" = "org.gnome.Loupe.desktop";
          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        };
      };
    };

    programs = {
      dankMaterialShell = {
        enable = true;
        enableColorPicker = false;
        enableDynamicTheming = false;
        niri.enableSpawn = true;
      };
    };
  };
}
