{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.desktops.niri;
in {
  options.presets.desktops.niri = {
    enable = mkEnableOption "niri preset";
  };

  config = mkIf cfg.enable {
    rum.desktops.niri = {
      enable = true;
      package = pkgs.niri-unstable;

      binds = {};

      config =
        # kdl
        ''
          config-notification { disable-failed; }
          hotkey-overlay { skip-at-startup; }
          prefer-no-csd
          screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"
          xwayland-satellite { path "xwayland-satellite"; }

          input {
              keyboard {
                  xkb {
                      layout "us"
                      options "caps:ctrl_modifier"
                  }
                  repeat-delay 600
                  repeat-rate 25
                  track-layout "global"
              }
              touchpad {
                  tap
                  natural-scroll
                  click-method "clickfinger"
              }
              warp-mouse-to-focus
          }

          cursor {
            hide-when-typing
            hide-after-inactive-ms 10000
          }

          // TODO: don't hard-code colors
          layout {
              gaps 8
              default-column-width { proportion 0.5; }
              preset-column-widths {
                  proportion 0.333333
                  proportion 0.5
                  proportion 0.666667
              }
              center-focused-column "on-overflow"
              always-center-single-column
              empty-workspace-above-first
              focus-ring {
                  width 2
                  urgent-color "#f38ba8"
                  active-color "#94e2d5"
                  inactive-color "#7f849c"
              }
              border { off; }
              background-color "#181825"
              shadow {
                  on
                  offset x=0.0 y=5.0
                  softness 30.0
                  spread 5.0
                  draw-behind-window false
                  color "#11111b"
                  inactive-color "#11111b"
              }
          }


          window-rule {
              geometry-corner-radius 10.0 10.0 10.0 10.0
              clip-to-geometry true
          }

          window-rule {
              match app-id="^firefox" title="^Picture-in-Picture$"
              open-floating true
          }

          // TODO: laptop-specific
          debug { ignore-drm-device "/dev/dri/renderD129"; }
          output "DP-1" {
              backdrop-color "#11111b"
              background-color "#181825"
              scale 1.250000
              transform "normal"
              position x=0 y=1440
              mode "2880x864@60.008000"
          }
          output "eDP-1" {
              backdrop-color "#11111b"
              background-color "#181825"
              scale 1.250000
              focus-at-startup
              transform "normal"
              position x=0 y=0
              mode "2800x1800@120.016000"
          }
          // input {
          //   tablet { map-to-output "eDP-1"; }
          //   touch { map-to-output "eDP-1"; }
          // }

          // TODO: recent-windows binds
        '';

      binds = {
        "Mod+Shift+Slash".action = "show-hotkey-overlay";

        "Mod+T" = {
          spawn = ["ghostty" "+new-window"];
          parameters.hotkey-overlay-title = "Open Ghostty";
        };
        "Mod+B" = {
          spawn = ["firefox-nightly"];
          parameters.hotkey-overlay-title = "Open Browser";
        };
        "Mod+Space" = {
          spawn = ["dms" "ipc" "spotlight" "toggle"];
          parameters.hotkey-overlay-title = "Application Launcher";
        };
        "Mod+Ctrl+B" = {
          spawn = ["dms" "ipc" "bar" "toggle"];
          parameters.hotkey-overlay-title = "Toggle DMS Bar";
        };
        "Mod+Ctrl+N" = {
          spawn = ["dms" "ipc" "notepad" "toggle"];
          parameters.hotkey-overlay-title = "Toggle DMS Notepad";
        };
        "Mod+X" = {
          spawn = ["dms" "ipc" "powermenu" "toggle"];
          parameters.hotkey-overlay-title = "Toggle DMS Power Menu";
        };
        "Super+Alt+L" = {
          spawn = ["dms" "ipc" "lock" "lock"];
          parameters.hotkey-overlay-title = "Lock";
        };
        "Mod+Ctrl+Shift+R" = {
          spawn = ["dms" "restart"];
          parameters.allow-when-locked = true;
          parameters.hotkey-overlay-title = "Restart DMS";
        };

        XF86AudioRaiseVolume = {
          spawn = ["dms" "ipc" "audio" "increment" "3"];
          parameters.allow-when-locked = true;
        };
        XF86AudioLowerVolume = {
          spawn = ["dms" "ipc" "audio" "decrement" "3"];
          parameters.allow-when-locked = true;
        };
        XF86AudioPlay = {
          spawn = ["dms" "ipc" "mpris" "playPause"];
          parameters.allow-when-locked = true;
        };
        XF86AudioStop = {
          spawn = ["dms" "ipc" "mpris" "stop"];
          parameters.allow-when-locked = true;
        };
        XF86AudioNext = {
          spawn = ["dms" "ipc" "mpris" "next"];
          parameters.allow-when-locked = true;
        };
        XF86AudioPrev = {
          spawn = ["dms" "ipc" "mpris" "previous"];
          parameters.allow-when-locked = true;
        };
        XF86AudioMute = {
          spawn = ["dms" "ipc" "audio" "mute"];
          parameters.allow-when-locked = true;
        };
        XF86AudioMicMute = {
          spawn = ["dms" "ipc" "audio" "micmute"];
          parameters.allow-when-locked = true;
        };

        XF86MonBrightnessUp = {
          spawn = ["dms" "ipc" "brightnessctl" "increment" "5"];
          parameters.allow-when-locked = true;
        };
        XF86MonBrightnessDown = {
          spawn = ["dms" "ipc" "brightnessctl" "decrement" "5"];
          parameters.allow-when-locked = true;
        };

        "Mod+O" = {
          action = "toggle-overview";
          parameters.repeat = false;
        };

        "Mod+Q" = {
          action = "close-window";
          parameters.repeat = false;
        };

        "Mod+H".action = "focus-column-left";
        "Mod+J".action = "focus-window-down";
        "Mod+K".action = "focus-window-up";
        "Mod+L".action = "focus-column-right";

        "Mod+Shift+H".action = "move-column-left";
        "Mod+Shift+J".action = "move-window-down";
        "Mod+Shift+K".action = "move-window-up";
        "Mod+Shift+L".action = "move-column-right";

        "Mod+Ctrl+H".action = "focus-monitor-left";
        "Mod+Ctrl+J".action = "focus-monitor-down";
        "Mod+Ctrl+K".action = "focus-monitor-up";
        "Mod+Ctrl+L".action = "focus-monitor-right";

        "Mod+Shift+Ctrl+H".action = "move-window-to-monitor-left";
        "Mod+Shift+Ctrl+J".action = "move-window-to-monitor-down";
        "Mod+Shift+Ctrl+K".action = "move-window-to-monitor-up";
        "Mod+Shift+Ctrl+L".action = "move-window-to-monitor-right";

        "Mod+U".action = "focus-workspace-down";
        "Mod+I".action = "focus-workspace-up";
        "Mod+Shift+U".action = "move-window-to-workspace-down";
        "Mod+Shift+I".action = "move-window-to-workspace-up";
        "Mod+Ctrl+U".action = "move-workspace-down";
        "Mod+Ctrl+I".action = "move-workspace-up";
        "Mod+Ctrl+Shift+U".action = "move-workspace-to-monitor-down";
        "Mod+Ctrl+Shift+I".action = "move-workspace-to-monitor-up";

        "Mod+1".action = "focus-workspace 1";
        "Mod+2".action = "focus-workspace 2";
        "Mod+3".action = "focus-workspace 3";
        "Mod+4".action = "focus-workspace 4";
        "Mod+5".action = "focus-workspace 5";
        "Mod+6".action = "focus-workspace 6";
        "Mod+7".action = "focus-workspace 7";
        "Mod+8".action = "focus-workspace 8";
        "Mod+9".action = "focus-workspace 9";
        "Mod+Shift+1".action = "move-window-to-workspace 1";
        "Mod+Shift+2".action = "move-window-to-workspace 2";
        "Mod+Shift+3".action = "move-window-to-workspace 3";
        "Mod+Shift+4".action = "move-window-to-workspace 4";
        "Mod+Shift+5".action = "move-window-to-workspace 5";
        "Mod+Shift+6".action = "move-window-to-workspace 6";
        "Mod+Shift+7".action = "move-window-to-workspace 7";
        "Mod+Shift+8".action = "move-window-to-workspace 8";
        "Mod+Shift+9".action = "move-window-to-workspace 9";

        "Mod+BracketLeft".action = "consume-or-expel-window-left";
        "Mod+BracketRight".action = "consume-or-expel-window-right";
        "Mod+Comma".action = "consume-window-into-column";
        "Mod+Period".action = "expel-window-from-column";

        "Mod+R".action = "switch-preset-column-width";
        "Mod+Shift+R".action = "switch-preset-window-height";
        "Mod+Ctrl+R".action = "reset-window-height";

        "Mod+Return".action = "maximize-window-to-edges";
        "Mod+F".action = "maximize-column";
        "Mod+Shift+F".action = "fullscreen-window";
        "Mod+Ctrl+F".action = "expand-column-to-available-width";

        "Mod+C".action = "center-column";
        "Mod+Ctrl+C".action = "center-visible-columns";

        "Mod+Minus".action = ''set-column-width "-10%"'';
        "Mod+Equal".action = ''set-column-width "+10%"'';

        "Mod+V".action = "toggle-window-floating";
        "Mod+Shift+V".action = "switch-focus-between-floating-and-tiling";

        "Mod+W".action = "toggle-column-tabbed-display";

        "XF86SelectiveScreenshot".action = "screenshot";
        "Print".action = "screenshot";
        "Shift+Print".action = "screenshot-window";
        "Ctrl+Print".action = "screenshot-screen";

        "Mod+Escape" = {
          action = "toggle-keyboard-shortcuts-inhibit";
          parameters.allow-inhibiting = false;
        };

        "Mod+Shift+P".action = "power-off-monitors";

        "Mod+Shift+E".action = "quit";
        "Ctrl+Alt+Delete".action = "quit";
      };
    };

    rum.programs.dank-material-shell = {
      enable = true;

      audioWavelength.enable = true;
      brightnessControl.enable = true;
      clipboard.enable = true;
      systemMonitoring.enable = true;
      systemSound.enable = true;

      integrations.niri.enable = true;
    };
  };
}
