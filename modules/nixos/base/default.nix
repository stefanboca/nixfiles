{
  config,
  lib,
  ...
}: let
  cfg = config.base;
in {
  imports = [
    ./cli.nix
    ./man.nix
    ./ssh.nix
  ];

  options.base = {
    enable = lib.mkEnableOption "Enable the base system module";

    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "stefan";
      description = "Primary user for permissions and defaults.";
    };

    boot.enable = lib.mkEnableOption "Enable boot config." // {default = true;};

    tz = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "The timezone of the machine.";
    };

    appimage.enable = lib.mkEnableOption "Enable appimage.";
  };

  config = lib.mkIf cfg.enable {
    boot = lib.mkIf cfg.boot.enable {
      loader = {
        limine = {
          enable = true;
          secureBoot.enable = true;
        };
        timeout = lib.mkDefault 1;
        efi.canTouchEfiVariables = true;
      };

      initrd = {
        verbose = false;
        systemd.enable = true;
      };

      plymouth.enable = true;

      tmp.useTmpfs = true;

      binfmt.emulatedSystems = ["aarch64-linux"];

      supportedFilesystems = {
        btrfs = true;
      };
    };
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
      irqbalance.enable = true;
      dbus.implementation = "broker";

      # needed for iwd
      gnome.gnome-keyring.enable = true;
    };

    zramSwap = {
      enable = true;
      algorithm = "lzo-rle";
      memoryPercent = 25;
    };

    programs.appimage = lib.mkIf cfg.appimage.enable {
      enable = true;
      binfmt = true;
    };
  };
}
