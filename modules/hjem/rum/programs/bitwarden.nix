{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.rum.programs.bitwarden;
in {
  options.rum.programs.bitwarden = {
    enable = mkEnableOption "bitwarden";

    package = mkPackageOption pkgs "bitwarden-desktop" {};
  };

  config = mkIf cfg.enable {
    packages = [cfg.package];

    systemd.services.bitwarden = {
      description = "Bitwarden";
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = getExe cfg.package;
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
