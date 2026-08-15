{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
    ./home.nix
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
      enableJIT = true;
      ensureUsers = [
        {
          name = "stefan";
          ensureClauses.superuser = true;
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
      drivers = with pkgs; [
        cnijfilter2
        epson-escpr2
      ];
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
}
