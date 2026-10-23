{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  json = pkgs.formats.json {};

  cfg = config.rum.services.rbw;
in {
  options.rum.services.rbw = {
    enable = mkEnableOption "rbw";
    package = mkPackageOption pkgs "rbw" {};
    pinentry.package = mkPackageOption pkgs "pinentry-gnome3" {};
    settings = mkOption {
      inherit (json) type;
      default = {};
    };
    integrations = {
      fish.enable = mkEnableOption "rbw ssh-agent integration with fish";
    };
  };

  config = mkIf cfg.enable {
    packages = [cfg.package];

    rum.services.rbw.settings.pinentry = mkDefault (getExe cfg.pinentry.package);

    xdg.config.files."rbw/config.json" = mkIf (cfg.settings != {}) {
      generator = json.generate "rbw-config.json";
      value = cfg.settings;
    };

    systemd.services.rbw-agent = {
      description = "rbw-agent";
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      restartTriggers = mkIf (cfg.settings != {}) [config.xdg.config.files."rbw/config.json".source];
      path = [cfg.pinentry.package];
      serviceConfig = {
        ExecStart = "${getExe' cfg.package "rbw-agent"} --no-daemonize";
        Restart = "always";
        RestartSec = 5;
      };
    };

    rum.programs.fish.earlyConfigFiles.rbw-agent = mkIf cfg.integrations.fish.enable ''
      set --global --export SSH_AUTH_SOCK $XDG_RUNTIME_DIR/rbw/ssh-agent-socket
    '';
  };
}
