{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.modules) mkAfter;

  niriConfigFile =
    pkgs.writeText "niri-laptop.kdl"
    # kdl
    ''
      output "eDP-1" {
        scale 1.25
        focus-at-startup
        position x=0 y=0
        mode "2800x1800@120.016000"
      }
      output "DP-1" {
        scale 1.25
        position x=0 y=1440
        mode "2880x864@60.008000"
        variable-refresh-rate
      }
      input {
        tablet {
          map-to-output "eDP-1"
        }
        touch {
          map-to-output "eDP-1"
        }
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
    autoEnable = true;
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

  systemd = {
    services.tor.wantedBy = lib.mkForce [];
    targets.postgresql.wantedBy = lib.mkForce [];
  };

  environment = {
    etc = {
      # emulate services.xserver.exportConfiguration = true without services.xserver.enable = true
      "X11/xkb".source = "${config.services.xserver.xkb.dir}";
    };
    sessionVariables = {
      XKB_CONFIG_ROOT = lib.mkForce "/etc/X11/xkb";
    };
  };

  services = {
    postgresql = {
      enable = true;
      ensureDatabases = ["stefan"];
      ensureUsers = [
        {
          name = "stefan";
          ensureClauses = {superuser = true;};
          ensureDBOwnership = true;
        }
      ];
    };
    tor = {
      enable = true;
      client.enable = true;
      relay.onionServices.radicle = {
        map = [8776];
      };
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    printing = {
      enable = true;
      drivers = [pkgs.cnijfilter2];
      webInterface = false; # this enabled prevents prevents exit on idle. use system-config-printer instead.
    };
    xserver.xkb = {
      layout = "us,gallium_rowstag";
      extraLayouts = {
        graphite = {
          description = "Graphite";
          languages = ["eng"];
          symbolsFile = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/xedrac/keyboard-layouts/7fc725da98a14aa187c156c06b426195106b05f5/linux/xkb/graphite";
            hash = "sha256-3BMRivNlOiurD1eGJh7uHbRUW0lTLj1VjP0ujimwm4w=";
          };
        };
        gallium_rowstag = {
          description = "Gallium v2 (rowstag)";
          languages = ["eng"];
          symbolsFile = pkgs.fetchurl {
            url = "https://github.com/GalileoBlues/Gallium/raw/21a8a7bb64a80acd67e06b5209e30559688121fe/Linux/xkb/gallium_rowstag";
            hash = "sha256-iUY1wdc+dbuOXp6vWIzUuDQxa31pz8vhCvMfc43o6ng=";
          };
        };
        meteorite = {
          description = "Meteorite";
          languages = ["eng"];
          symbolsFile = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/xedrac/keyboard-layouts/7fc725da98a14aa187c156c06b426195106b05f5/linux/xkb/meteorite";
            hash = "sha256-YWghWBy65aTvCwNHse13Ff2eNLwir9ugtQQsieMaQ7Q=";
          };
        };
      };
    };
  };

  programs = {
    nh.flake = "/home/stefan/src/nixfiles";
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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
  boot.binfmt = {
    emulatedSystems = ["aarch64-linux"];
    preferStaticEmulators = true;
  };

  hjem = {
    specialArgs = {inherit inputs self;};
    extraModules = [self.hjemModules.stefan];
    clobberByDefault = true;

    users.stefan = {
      enable = true;
      presets.users.stefan.enable = true;

      packages = with pkgs; [
        # keep-sorted start
        beets
        bitwarden-desktop
        crosspipe
        easyeffects
        esphome
        fluent-reader
        freecad
        geogebra6
        gnome-decoder
        gnome-pomodoro
        imv
        libreoffice
        miro
        nicotine-plus
        podman-compose
        prusa-slicer
        radicle-desktop
        radicle-node
        radicle-tui
        rnote
        signal-desktop
        system-config-printer
        telegram-desktop
        zotero
        zulip
        # keep-sorted end
        pkgsCuda.blender
        # calibre
        # musescore
        # xournalpp
      ];

      rum.misc.dconf = {
        settings."org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = ["BOE" "0x0a8d" "0x00000000"];
        locks = ["org/gnome/desktop/peripherals/touchscreens/04f3:2f2a/output"];
      };

      rum.services = {
        rbw = {
          enable = true;
          integrations.fish.enable = true;
        };
      };

      rum.programs = {
        zed-editor = {
          enable = true;
          extraPackages = with pkgs; [
            # keep-sorted start
            alejandra
            clang-tools
            emmylua-ls
            harper
            jdt-language-server
            just-lsp
            keep-sorted
            lua-language-server
            nil
            nixd
            nixfmt
            ruff
            snv.rust-analyzer
            tailwindcss-language-server
            tinymist
            tombi
            ty
            vscode-langservers-extracted
            wgsl-analyzer
            yaml-language-server
            # keep-sorted end
          ];
        };
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
