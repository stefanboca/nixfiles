{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.rum.services.rbw;
in {
  options.rum.services.rbw = {
    enable = mkEnableOption "rbw";
    package = mkPackageOption pkgs "rbw" {};
    pinentry.package = mkPackageOption pkgs "pinentry-gnome3" {};

    integrations = {
      fish.enable = mkEnableOption "rbw ssh-agent integration with fish";
    };
  };

  config = mkIf cfg.enable {
    packages = [cfg.package];

    systemd.services.rbw-agent = {
      description = "rbw-agent";
      wantedBy = ["graphical-session.target"];
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
