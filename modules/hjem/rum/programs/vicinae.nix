{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkForce mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  json = pkgs.formats.json {};

  cfg = config.rum.programs.vicinae;
in {
  options.rum.programs.vicinae = {
    enable = mkEnableOption "vicinae";

    package = mkPackageOption pkgs "vicinae" {};

    settings = mkOption {
      inherit (json) type;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = [cfg.package];

    systemd.services.vicinae = {
      description = "Vicinae Server";
      documentation = ["https://docs.vicinae.com"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      restartTriggers = [cfg.package];

      # unset nix-generated path
      environment.PATH = mkForce null;

      serviceConfig = {
        ExecStart = "${getExe cfg.package} server";
        Restart = "on-failure";
      };
    };

    xdg.config.files."vicinae/settings.json" = mkIf (cfg.settings != {}) {
      generator = json.generate "vicinae-settings.json";
      value = cfg.settings;
    };
  };
}
