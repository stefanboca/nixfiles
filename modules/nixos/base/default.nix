{
  config,
  lib,
  ...
}:

let
  cfg = config.base;
in
{
  imports = [
    ./cli.nix
    ./ssh.nix
  ];

  options.base = {
    enable = lib.mkEnableOption "Enable the base system module";

    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "stefan";
      description = "Primary user for permissions and defaults.";
    };

    boot.enable = lib.mkEnableOption "Enable boot config" // {
      default = true;
    };

    tz = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "The timezone of the machine.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = lib.mkIf cfg.boot.enable {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = lib.mkDefault 3;
          consoleMode = "max";
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

      binfmt.emulatedSystems = [ "aarch64-linux" ];

      supportedFilesystems = {
        btrfs = true;
      };
    };
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

    console.useXkbConfig = true;

    time.timeZone = cfg.tz;
    i18n.defaultLocale = "en_US.UTF-8";

    networking = {
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      nftables.enable = true;
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
  };
}
