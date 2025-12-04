{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) mapAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) attrsOf path;

  json = pkgs.formats.json {};

  cfg = config.rum.programs.vesktop;
in {
  options.rum.programs.vesktop = {
    enable = mkEnableOption "vesktop";

    package = mkPackageOption pkgs "vesktop" {nullable = true;};

    settings = mkOption {
      inherit (json) type;
      default = {};
    };

    vencord = {
      settings = mkOption {
        inherit (json) type;
        default = {};
      };

      themes = mkOption {
        type = attrsOf path;
        default = {};
      };
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    xdg.config.files =
      {
        "vesktop/settings.json" = mkIf (cfg.settings != {}) {
          source = json.generate "vesktop-settings.json" cfg.settings;
        };
        "vesktop/settings/settings.json" = mkIf (cfg.vencord.settings != {}) {
          source = json.generate "vesktop-vencord-settings.json" cfg.vencord.settings;
        };
      }
      // mapAttrs' (name: value: nameValuePair "vesktop/themes/${name}.css" {source = value;}) cfg.vencord.themes;
  };
}
