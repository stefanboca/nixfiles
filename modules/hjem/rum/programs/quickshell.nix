{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) attrsOf listOf package path;

  cfg = config.rum.programs.quickshell;
in {
  options.rum.programs.quickshell = {
    enable = mkEnableOption "quickshell";

    package = mkPackageOption pkgs "quickshell" {nullable = true;};
    extraBuildInputs = mkOption {
      type = listOf package;
      default = [];
    };

    configs = mkOption {
      type = attrsOf path;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [
      (cfg.package.overrideAttrs (prevAttrs: {buildInputs = (prevAttrs.buildInputs or []) ++ cfg.extraBuildInputs;}))
    ];

    xdg.config.files = mkIf (cfg.configs != {}) (
      mapAttrs' (name: path: nameValuePair "quickshell/${name}" {source = path;}) cfg.configs
    );
  };
}
