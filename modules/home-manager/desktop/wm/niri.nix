{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.wm;
in
{
  options.desktop.wm.enableNiri = lib.mkEnableOption "niri WM";

  config = lib.mkIf cfg.enableNiri {
    programs.niri.settings = {
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
      hotkey-overlay.skip-at-startup = true;
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;
      cursor = {
        hide-when-typing = true;
        hide-after-inactive-ms = 10000;
      };
      spawn-at-startup = [
        { command = [ (lib.getExe pkgs.mako) ]; }
        {
          command = [
            (lib.getExe pkgs.swayidle)
            "-w"
            "timeout"
            "300"
            "loginctl lock-session"
            "timeout"
            "301"
            "niri msg action power-off-monitors"
          ];
        }
      ];

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
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }
          { proportion = 1.0 / 2.0; }
          { proportion = 2.0 / 3.0; }
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

      layer-rules = [
        {
          matches = [ { namespace = "^wallpaper$"; } ];
          place-within-backdrop = true;
        }
      ];

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

      binds = with config.lib.niri.actions; {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+T" = {
          hotkey-overlay.title = "Open Ghostty";
          action = spawn [
            (lib.getExe config.programs.ghostty.package)
            "--launched-from=desktop"
          ];
        };
        "Mod+B" = {
          hotkey-overlay.title = "Open Browser";
          action = spawn (lib.getExe config.programs.firefox.package);
        };
        "Mod+D" = {
          hotkey-overlay.title = "Application Launcher";
          action = spawn (lib.getExe pkgs.fuzzel);
          # action = spawn [ "env" "WGPU_POWER_PREF=low" "centerpiece" ];
        };

        XF86AudioRaiseVolume = {
          allow-when-locked = true;
          action = spawn [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1+"
          ];
        };
        XF86AudioLowerVolume = {
          allow-when-locked = true;
          action = spawn [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1-"
          ];
        };
        XF86AudioNext = {
          allow-when-locked = true;
          action = spawn [
            "playerctl"
            "next"
          ];
        };
        XF86AudioPrev = {
          allow-when-locked = true;
          action = spawn [
            "playerctl"
            "previous"
          ];
        };
        XF86AudioMute = {
          allow-when-locked = true;
          action = spawn [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
        };
        XF86AudioMicMute = {
          allow-when-locked = true;
          action = spawn [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];
        };

        XF86MonBrightnessUp = {
          allow-when-locked = true;
          action = spawn [
            "brightnessctl"
            "--class=backlight"
            "set"
            "+10%"
          ];
        };
        XF86MonBrightnessDown = {
          allow-when-locked = true;
          action = spawn [
            "brightnessctl"
            "--class=backlight"
            "set"
            "10%-"
          ];
        };

        "Mod+O" = {
          repeat = false;
          action = toggle-overview;
        };

        "Mod+Q".action = close-window;

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

        "Print".action = screenshot;
        "Shift+Print".action = screenshot-window;
        "Ctrl+Print".action.screenshot-screen = { };

        "Mod+Escape" = {
          allow-inhibiting = false;
          action = toggle-keyboard-shortcuts-inhibit;
        };

        "Mod+Shift+P".action = power-off-monitors;

        "Mod+Shift+E".action = quit;
        "Ctrl+Alt+Delete".action = quit;
      };
    };

    programs = {
      swaylock = {
        enable = true;
        settings = {
          indicator-caps-lock = true;
          indicator-idle-visible = true;
        };
      };
    };

    services.mako = {
      enable = true;
      settings = {
        default-timeout = 10000; # 10 seconds
      };
    };
  };
}
