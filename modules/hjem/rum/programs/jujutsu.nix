{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  toml = pkgs.formats.toml {};

  cfg = config.rum.programs.jujutsu;
in {
  options.rum.programs.jujutsu = {
    enable = mkEnableOption "jujutsu";

    package = mkPackageOption pkgs "jujutsu" {nullable = true;};

    settings = mkOption {
      inherit (toml) type;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    xdg.config.files."jujutsu/config.toml" = mkIf (cfg.settings != {}) {
      source = toml.generate "jujutsu-config.toml" cfg.settings;
    };
  };
}
