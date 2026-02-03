{
  config,
  lib,
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

      config =
        # kdl
        ''
          hotkey-overlay { skip-at-startup; }
          prefer-no-csd
          screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"

          cursor {
            hide-when-typing
            hide-after-inactive-ms 10000
          }

          input {
            keyboard {
              xkb {
                layout "us"
                options "caps:ctrl_modifier"
              }
            }
            touchpad {
              tap
              natural-scroll
              click-method "clickfinger"
            }
            warp-mouse-to-focus
          }

          layout {
            always-center-single-column
            center-focused-column "on-overflow"
            empty-workspace-above-first
            gaps 3

            default-column-width { proportion 0.5; }
            preset-column-widths {
              proportion 0.333333
              proportion 0.5
              proportion 0.666667
            }

            focus-ring { off; }
            border {
              width 3
              active-gradient from="hsl(183deg, 80%, 50%)" to="hsl(183deg, 80%, 50%)" angle=45 relative-to="workspace-view" in="oklch longer hue"
              inactive-gradient from="hsl(183deg, 40%, 30%)" to="hsl(183deg, 40%, 30%)" angle=45 relative-to="workspace-view" in="oklch longer hue"
              urgent-gradient from="hsl(320deg, 80%, 50%)" to="hsl(40deg, 80%, 50%)" angle=45 in="oklch shorter hue"
            }

            tab-indicator {
              length total-proportion=0.75
              gaps-between-tabs 2
              place-within-column
            }

            shadow {
              on
            }
          }

          // TODO: recent-windows binds
          recent-windows {
            highlight {
              padding 30
              corner-radius 30
            }
          }

          window-rule {
            clip-to-geometry true
              geometry-corner-radius 10.0 10.0 10.0 10.0
          }

          window-rule {
              match app-id="^firefox" title="^Picture-in-Picture$"
              open-floating true
          }
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
          spawn = ["noctalia-shell" "ipc" "call" "launcher" "toggle"];
          parameters.hotkey-overlay-title = "Application Launcher";
        };
        "Mod+Ctrl+B" = {
          spawn = ["noctalia-shell" "ipc" "call" "bar" "toggle"];
          parameters.hotkey-overlay-title = "Toggle Bar";
        };
        "Mod+Ctrl+W" = {
          spawn = ["noctalia-shell" "ipc" "call" "desktopWidgets" "toggle"];
          parameters.hotkey-overlay-title = "Toggle Desktop Widgets";
        };
        "Mod+X" = {
          spawn = ["noctalia-shell" "ipc" "call" "sessionMenu" "toggle"];
          parameters.hotkey-overlay-title = "Toggle Session Menu";
        };
        "Mod+N" = {
          spawn = ["noctalia-shell" "ipc" "call" "nightLight" "toggle"];
          parameters.hotkey-overlay-title = "Toggle Night Light";
        };
        "Super+Alt+L" = {
          spawn = ["noctalia-shell" "ipc" "call" "lockScreen" "lock"];
          parameters.hotkey-overlay-title = "Lock";
        };
        "Mod+Ctrl+Shift+P" = {
          spawn = ["noctalia-shell" "ipc" "call" "powerProfile" "toggleNoctaliaPerformance"];
          parameters.hotkey-overlay-title = "Toggle Noctalia Performance Mode";
        };
        "Mod+Ctrl+Shift+R" = {
          spawn = ["systemctl" "--user" "restart" "noctalia-shell.service"];
          parameters.hotkey-overlay-title = "Restart Noctalia Shell";
          parameters.allow-when-locked = true;
        };

        XF86AudioRaiseVolume = {
          spawn = ["noctalia-shell" "ipc" "call" "volume" "increase"];
          parameters.allow-when-locked = true;
        };
        XF86AudioLowerVolume = {
          spawn = ["noctalia-shell" "ipc" "call" "volume" "decrease"];
          parameters.allow-when-locked = true;
        };
        XF86AudioMute = {
          spawn = ["noctalia-shell" "ipc" "call" "volume" "muteOutput"];
          parameters.allow-when-locked = true;
        };
        XF86AudioMicMute = {
          spawn = ["noctalia-shell" "ipc" "call" "volume" "muteInput"];
          parameters.allow-when-locked = true;
        };
        XF86AudioPlay = {
          spawn = ["noctalia-shell" "ipc" "call" "media" "playPause"];
          parameters.allow-when-locked = true;
        };
        XF86AudioStop = {
          spawn = ["noctalia-shell" "ipc" "call" "media" "stop"];
          parameters.allow-when-locked = true;
        };
        XF86AudioNext = {
          spawn = ["noctalia-shell" "ipc" "call" "media" "next"];
          parameters.allow-when-locked = true;
        };
        XF86AudioPrev = {
          spawn = ["noctalia-shell" "ipc" "call" "media" "previous"];
          parameters.allow-when-locked = true;
        };

        XF86MonBrightnessUp = {
          spawn = ["noctalia-shell" "ipc" "call" "brightness" "increase"];
          parameters.allow-when-locked = true;
        };
        XF86MonBrightnessDown = {
          spawn = ["noctalia-shell" "ipc" "call" "brightness" "decrease"];
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
        "Print" = {
          action = "screenshot";
          parameters.hotkey-overlay-title = "Screenshot";
        };
        "Shift+Print" = {
          action = "screenshot-window";
          parameters.hotkey-overlay-title = "Screenshot Window";
        };
        "Ctrl+Print" = {
          action = "screenshot-screen";
          parameters.hotkey-overlay-title = "Screenshot Screen";
        };

        "Mod+Escape" = {
          action = "toggle-keyboard-shortcuts-inhibit";
          parameters.allow-inhibiting = false;
        };

        "Mod+Shift+P".action = "power-off-monitors";

        "Mod+Shift+E".action = "quit";
        "Ctrl+Alt+Delete".action = "quit";
      };
    };
  };
}
