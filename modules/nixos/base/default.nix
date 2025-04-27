{ config, lib, ... }:

let
  cfg = config.base;
in
{
  imports = [
    ./cli.nix
    ./gpu.nix
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
      initrd.systemd.enable = true;
      tmp.useTmpfs = true;
      binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

    time.timeZone = cfg.tz;

    networking = {
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      nftables.enable = true;
    };
    # needed for iwd
    services.gnome.gnome-keyring.enable = true;

    services.fstrim.enable = true;
    services.irqbalance.enable = true;

    zramSwap = {
      enable = true;
      algorithm = "lzo-rle";
      memoryPercent = 25;
    };

    services.dbus.implementation = "broker";

    # use newer switch-to-configuration
    system.switch = {
      enable = false;
      enableNg = true;
    };
  };
}
