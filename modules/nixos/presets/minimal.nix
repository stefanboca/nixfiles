{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.attrsets) attrValues;
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
        allowed-users = ["root" "@wheel"];
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        keep-outputs = true; # don't garbage-collect build-time dependencies
        trace-import-from-derivation = true;
        trusted-users = ["root" "@wheel"];
        use-xdg-base-directories = true;
        warn-dirty = false;

        substituters = ["https://cache.nixos.org" "https://nix-community.cachix.org"];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      registry = {
        n.flake = inputs.nixpkgs;
        nixpkgs.flake = inputs.nixpkgs;
      };
    };

    nixpkgs = {
      overlays = attrValues self.overlays;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };

    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";

    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

    boot = {
      initrd.systemd.enable = true;
      loader.timeout = 1;
      supportedFilesystems.btrfs = true;
      tmp.useTmpfs = true;
    };

    console = {
      earlySetup = true;
      useXkbConfig = true;
    };

    services = {
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true; # needed for iwd
      irqbalance.enable = true;
      openssh.generateHostKeys = true;
      thermald.enable = true;
      userborn.enable = true;
    };

    system = {
      etc.overlay.enable = true;
      nixos-init.enable = true;
      tools.nixos-generate-config.enable = false;
    };

    networking = {
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      modemmanager.enable = false; # enabled by nnetworkmanager
      nftables.enable = true;
      firewall.enable = true;
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
        generateCaches = mkDefault false;
        man-db.enable = false;
        mandoc.enable = true;
      };
    };
  };
}
