{
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkAfter mkForce;

  pkgs-cuda = import pkgs.path {
    inherit (pkgs) overlays;
    inherit (pkgs.stdenv.hostPlatform) system;
    config = pkgs.config // {cudaSupport = true;};
  };

  niriConfigFile =
    pkgs.writeText "niri-laptop.kdl"
    # kdl
    ''
      // don't use NVIDIA gpu
      debug { ignore-drm-device "/dev/dri/renderD129"; }
      output "eDP-1" {
          scale 1.250000
          focus-at-startup
          position x=0 y=0
          mode "2800x1800@120.016000"
      }
      output "DP-1" {
          scale 1.250000
          position x=0 y=1440
          mode "2880x864@60.008000"
          variable-refresh-rate
      }
      input {
        tablet { map-to-output "eDP-1"; }
        touch { map-to-output "eDP-1"; }
      }
    '';
in {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
    ./screenpad.nix
  ];

  networking.hostName = "laptop";
  system.stateVersion = "26.05";

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "teal";
  };

  presets = {
    common.enable = true;
    desktop.enable = true;
    gaming.enable = true;
    programs.niri.enable = true;

    users.stefan.enable = true;
  };

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    printing = {
      enable = true;
      drivers = [pkgs.cnijfilter2];
    };
  };

  programs = {
    nh.flake = "/home/stefan/src/nixfiles";
    obs-studio.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    dconf = {
      enable = true;
      profiles.user = {
        userDbs = ["user" "hjem"];
      };
    };
  };

  hjem = {
    specialArgs = {inherit inputs self;};
    extraModules = [self.hjemModules.stefan];
    clobberByDefault = true;

    users.stefan = {
      enable = true;
      presets.users.stefan.enable = true;

      packages = with pkgs; [
        bitwarden-desktop
        calibre
        easyeffects
        esphome
        fluent-reader
        freecad
        geogebra6
        gnome-decoder
        helvum
        imv
        libreoffice
        miro
        prusa-slicer
        qpwgraph
        rnote
        signal-desktop
        telegram-desktop
        pkgs-cuda.blender
        # musescore
        # xournalpp
        # zotero
      ];

      rum.misc.dconf = {
        settings."org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = ["BOE" "0x0a8d" "0x00000000"];
        locks = ["org/gnome/desktop/peripherals/touchscreens/04f3:2f2a/output"];
      };

      rum.desktops.niri = {
        config =
          mkAfter
          # kdl
          ''
            include "${niriConfigFile}"
          '';
        binds = {
          "XF86MonBrightnessUp".spawn = mkForce ["dms" "ipc" "brightness" "increment" "5" "backlight:intel_backlight"];
          "XF86MonBrightnessDown".spawn = mkForce ["dms" "ipc" "brightness" "decrement" "5" "backlight:intel_backlight"];
          "Shift+XF86MonBrightnessUp" = {
            spawn = ["dms" "ipc" "brightness" "increment" "5" "backlight:asus_screenpad"];
            parameters.allow-when-locked = true;
          };
          "Shift+XF86MonBrightnessDown" = {
            spawn = ["dms" "ipc" "brightness" "decrement" "5" "backlight:asus_screenpad"];
            parameters.allow-when-locked = true;
          };
          "XF86DisplayToggle" = {
            spawn = ["toggle-screenpad-backlight"];
            parameters.allow-when-locked = true;
          };
          "XF86Launch1" = {
            spawn = ["dms" "ipc" "mpris" "playPause"];
            parameters.allow-when-locked = true;
          };
          "Mod+XF86Launch2".action = "focus-monitor-next";
          "Mod+Shift+XF86Launch2".action = "move-window-to-monitor-next";
          "Mod+Ctrl+XF86Launch2".action = "move-workspace-to-monitor-next";
          "XF86Launch2".action = "focus-monitor-previous";
          "Shift+XF86Launch2".action = "move-window-to-monitor-previous";
          "Ctrl+XF86Launch2".action = "move-workspace-to-monitor-previous";
        };
      };
    };
  };
}
