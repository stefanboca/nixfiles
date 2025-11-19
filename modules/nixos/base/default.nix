{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.base;
in {
  imports = [
    ./cli.nix
    ./docs.nix
    ./ssh.nix
  ];

  options.base = {
    enable = lib.mkEnableOption "Enable the base system module";
    appimage.enable = lib.mkEnableOption "Enable appimage.";
    boot.enable = lib.mkEnableOption "Enable boot config." // {default = true;};
    perllessActivation.enable = lib.mkEnableOption "Enable perlless activation." // {default = true;};

    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "stefan";
      description = "Primary user for permissions and defaults.";
    };

    tz = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "The timezone of the machine.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nix.package = pkgs.nixVersions.latest;

      systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

      console = {
        earlySetup = true;
        useXkbConfig = true;
      };

      time.timeZone = cfg.tz;
      i18n.defaultLocale = "en_US.UTF-8";

      networking = {
        networkmanager = {
          enable = true;
          wifi.backend = "iwd";
        };
        modemmanager.enable = false; # enabled by nnetworkmanager
        nftables.enable = true;
        firewall.enable = true;
      };

      services = {
        dbus.implementation = "broker";
        gnome.gnome-keyring.enable = true; # needed for iwd
        irqbalance.enable = true;
      };

      zramSwap = {
        enable = true;
        algorithm = "lzo-rle";
        memoryPercent = 25;
      };
    }
    (lib.mkIf cfg.boot.enable {
      boot = {
        loader = {
          limine = {
            enable = true;
            secureBoot.enable = true;
          };
          timeout = lib.mkDefault 1;
          efi.canTouchEfiVariables = true;
        };

        initrd.systemd.enable = true;
        plymouth.enable = true;
        tmp.useTmpfs = true;
        binfmt.emulatedSystems = ["aarch64-linux"];
        supportedFilesystems.btrfs = true;
      };
    })
    (lib.mkIf cfg.appimage.enable {
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
    })
    (lib.mkIf cfg.perllessActivation.enable {
      # Remove perl from activation
      boot.initrd.systemd.enable = true;
      system.etc.overlay.enable = true;
      services.userborn.enable = true;

      # Random perl remnants
      system.tools.nixos-generate-config.enable = false;
      boot.loader.grub.enable = lib.mkDefault false;
      environment.defaultPackages = lib.mkDefault [];
      documentation.info.enable = lib.mkDefault false;
      documentation.nixos.enable = lib.mkDefault false;
    })
  ]);
}
