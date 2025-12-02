{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;

  toml = pkgs.formats.toml {};

  cfg = config.rum.programs.jjui;
in {
  options.rum.programs.jjui = {
    enable = mkEnableOption "jjui";

    package = mkPackageOption pkgs "jjui" {nullable = true;};

    settings = mkOption {
      inherit (toml) type;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    xdg.config.files."jjui/config.toml" = mkIf (cfg.settings != {}) {
      source = toml.generate "jjui-config.toml" cfg.settings;
    };
  };
}
