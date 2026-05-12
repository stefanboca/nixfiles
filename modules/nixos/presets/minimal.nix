{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.minimal;
in {
  options.presets.minimal = {
    enable = mkEnableOption "minimal preset";
  };

  config = mkIf cfg.enable {
    nix = {
      channel.enable = false;
      package = pkgs.nixVersions.latest;
      settings = {
        # keep-sorted start block=yes
        allowed-users = ["root" "@wheel"];
        auto-allocate-uids = true;
        auto-optimise-store = true;
        experimental-features = [
          "auto-allocate-uids"
          "blake3-hashes"
          "ca-derivations"
          "cgroups"
          "dynamic-derivations"
          "flakes"
          "nix-command"
          "pipe-operators"
          "recursive-nix"
        ];
        keep-outputs = true;
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.flox.dev"
        ];
        trace-import-from-derivation = true;
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        ];
        trusted-users = ["@wheel"];
        use-cgroups = true;
        use-xdg-base-directories = true;
        warn-dirty = false;
        # keep-sorted end
      };

      registry = {
        n.flake = inputs.nixpkgs;
        nixpkgs.flake = inputs.nixpkgs;
      };
    };

    nixpkgs = {
      overlays = removeAttrs self.overlays ["ghostty" "zed-editor"] |> attrValues;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };

    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";

    boot = {
      initrd.systemd = {
        enable = true;
        dbus.enable = true;
      };
      loader.timeout = 1;
      supportedFilesystems.btrfs = true;
      tmp.useTmpfs = true;
    };

    console = {
      earlySetup = true;
      # TODO: fix when XKB_CONFIG_ROOT is out of store (use services.xserver.xkb.dir instead?)
      # useXkbConfig = true;
    };

    systemd = {
      network = {
        wait-online.enable = false;
        networks = {
          "99-ethernet-default-dhcp".networkConfig.MulticastDNS = true;
          "99-wireless-client-dhcp".networkConfig.MulticastDNS = true;
        };
      };
      oomd = {
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
        settings.OOM.DefaultMemoryPressureLimit = "90%";
      };
      services = {
        NetworkManager-wait-online.enable = false;
        # needed for kmscon to pick up services.xserver.xkb.extraLayouts
        # TODO: upstream?
        "kmsconvt@".serviceConfig.Environment =
          lib.mkIf
          (config.services.kmscon.useXkbConfig && config.environment.sessionVariables ? XKB_CONFIG_ROOT)
          ["XKB_CONFIG_ROOT=${config.environment.sessionVariables.XKB_CONFIG_ROOT}"];
      };
    };

    services = {
      # keep-sorted start block=yes
      dbus.implementation = "broker";
      gnome = {
        gnome-keyring.enable = true; # needed for iwd
        gcr-ssh-agent.enable = false; # enabled by gnome-keyring but I use bitwarden
      };
      irqbalance.enable = true;
      kmscon = {
        enable = true;
        hwRender = true; # ideally this would be mkIf hardware.graphics.enable, but that causes infinite recursion.
        term = "xterm-256color";
        useXkbConfig = true;
      };
      openssh.generateHostKeys = true;
      resolved = {
        enable = true;
        settings.Resolve = {
          DNSOverTLS = "opportunistic";
          LLMNR = false;
          MulticastDNS = true;
        };
      };
      thermald.enable = true;
      userborn.enable = true;
      # keep-sorted end
    };

    system = {
      etc.overlay.enable = true;
      nixos-init.enable = true;
      tools.nixos-generate-config.enable = false;
    };

    networking = {
      # keep-sorted start block=yes
      firewall = {
        enable = true;
        allowedUDPPorts = [5353]; # mdns
      };
      modemmanager.enable = false; # enabled by nnetworkmanager
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.backend = "iwd";
        settings = {
          connection.mdns = 1; # resolve but don't register hostname
        };
      };
      nftables.enable = true;
      useHostResolvConf = false; # conflicts with systemd-resolved
      useNetworkd = true; # use networkd instead of the pile of shell scripts
      # keep-sorted end
    };

    users.mutableUsers = false;

    programs = {
      command-not-found.enable = false;
      fish.enable = true;
    };

    environment.defaultPackages = [];
    environment.systemPackages = with pkgs; [
      # keep-sorted start
      age
      bat
      cifs-utils
      curl
      dnsutils
      e2fsprogs
      efibootmgr
      eza
      fd
      file
      git
      inotify-tools
      lsb-release
      lshw
      lsof
      nmap
      ouch
      parted
      pciutils
      powertop
      psmisc
      ripgrep
      rsync
      sbctl
      sops
      ssh-to-age
      strace
      usbutils
      vim
      wget
      # keep-sorted end
    ];

    documentation = {
      doc.enable = false;
      info.enable = false;
      nixos.enable = false;
      man = {
        cache.enable = mkDefault false;
        man-db.enable = false;
        mandoc.enable = true;
      };
    };
  };
}
