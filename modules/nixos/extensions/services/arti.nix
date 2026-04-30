{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  toml = pkgs.formats.toml {};

  configFile = toml.generate "arti.toml" (cfg.settings
    // {
      storage = {
        cache_dir = "/var/cache/arti";
        state_dir = "/var/lib/arti";
        port_info_file = "/run/arti/port_info.json";
      };
    });

  cfg = config.services.arti;
in {
  options.services.arti = {
    enable = mkEnableOption "arti";
    package = mkPackageOption pkgs "arti" {};
    settings = mkOption {
      inherit (toml) type;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."arti/arti.toml".source = configFile;
    };
    systemd.services.arti = {
      description = "Arti Tor Proxy";
      reloadTriggers = [configFile];
      serviceConfig = {
        ExecStart = "${getExe cfg.package} --config /etc/arti/arti.toml proxy";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        KillSignal = "SIGINT";
        LimitNOFILE = 16384;

        Restart = "on-failure";
        RestartSec = 5;

        User = "arti";
        Group = "arti";
        DynamicUser = true;

        CacheDirectory = "arti";
        CacheDirectoryMode = "0700";
        ConfigurationDirectory = "arti";
        RuntimeDirectory = "arti";
        StateDirectory = "arti";
        StateDirectoryMode = "0700";

        UMask = "0066";
        AmbientCapabilities = [""];
        CapabilityBoundingSet = [""];
        DeviceAllow = [""];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = [
          ""
          "@system-service"
          "~@aio"
          "~@chown"
          "~@keyring"
          "~@memlock"
          "~@resources"
          "~@setuid"
          "~@timer"
        ];
        SystemCallArchitectures = "native";
      };
    };
  };
}
