{
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkAfter;

  pkgs-cuda = import pkgs.path {
    inherit (pkgs) overlays;
    inherit (pkgs.stdenv.hostPlatform) system;
    config = pkgs.config // {cudaSupport = true;};
  };

  niriConfigFile =
    pkgs.writeText "niri-laptop.kdl"
    # kdl
    ''
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
      webInterface = false; # this enabled prevents prevents exit on idle. use system-config-printer instead.
    };
  };

  programs = {
    nh.flake = "/home/stefan/src/nixfiles";
    obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {browserSupport = false;}; # browser support is a whole 2GB that I don't use
    };
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
    zoom-us = {
      enable = true;
      package = pkgs.zoom-us.override {
        gnomeXdgDesktopPortalSupport = true;
      };
    };
  };

  networking.networkmanager.plugins = [pkgs.networkmanager-openconnect];

  hjem = {
    specialArgs = {inherit inputs self;};
    extraModules = [self.hjemModules.stefan];
    clobberByDefault = true;

    users.stefan = {
      enable = true;
      presets.users.stefan.enable = true;

      environment.sessionVariables = {
        SSH_AUTH_SOCK = "/home/stefan/.bitwarden-ssh-agent.sock"; # TODO: use config.directory
      };

      packages = with pkgs; [
        # keep-sorted start
        # beets
        bitwarden-desktop
        crosspipe
        easyeffects
        esphome
        fluent-reader
        freecad
        geogebra6
        gnome-decoder
        imv
        # libreoffice
        miro
        prusa-slicer
        qpwgraph
        rnote
        signal-desktop
        system-config-printer
        telegram-desktop
        # keep-sorted end
        pkgs-cuda.blender
        # calibre
        # musescore
        # xournalpp
        # zotero
      ];

      rum.misc.dconf = {
        settings."org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = ["BOE" "0x0a8d" "0x00000000"];
        locks = ["org/gnome/desktop/peripherals/touchscreens/04f3:2f2a/output"];
      };

      rum.programs.zed-editor = {
        enable = true;
        extraPackages = with pkgs; [
          # keep-sorted start
          alejandra
          harper
          keep-sorted
          nil
          nixd
          nixfmt
          ruff
          snv.rust-analyzer
          tinymist
          tombi
          ty
          vscode-langservers-extracted
          # keep-sorted end
        ];
      };

      rum.desktops.niri = {
        config =
          mkAfter
          # kdl
          ''
            include "${niriConfigFile}"
            include optional=true "dev.kdl"
          '';
        binds = {
          "XF86DisplayToggle" = {
            spawn = ["toggle-screenpad-backlight"];
            parameters.allow-when-locked = true;
          };
          "XF86Launch1" = {
            spawn = ["noctalia-shell" "ipc" "call" "media" "playPause"];
            parameters.allow-when-locked = true;
          };
          "Mod+XF86Display".action = "focus-monitor-next";
          "Mod+Shift+XF86Display".action = "move-window-to-monitor-next";
          "Mod+Ctrl+XF86Display".action = "move-workspace-to-monitor-next";
          "XF86Display".action = "focus-monitor-previous";
          "Shift+XF86Display".action = "move-window-to-monitor-previous";
          "Ctrl+XF86Display".action = "move-workspace-to-monitor-previous";
        };
      };
    };
  };
}
