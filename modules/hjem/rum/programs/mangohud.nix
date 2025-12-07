{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.strings) concatMapStringsSep concatMapAttrsStringsSep;
  inherit (lib.trivial) isBool pipe;
  inherit (lib.types) attrsOf bool float int listOf oneOf path str;

  renderOption = option:
    {
      bool = "0"; # "on/off" opts are disabled with `=0`
      list = concatMapStringsSep "," toString option;
    }.${
      builtins.typeOf option
    } or (toString
      option);
  renderLine = k: v: (
    if (isBool v && v)
    then k
    else "${k}=${renderOption v}"
  );
  renderSettings = attrs: concatMapAttrsStringsSep "\n" renderLine attrs + "\n";

  settingsType = oneOf [bool int float str path (listOf (oneOf [int str]))];

  cfg = config.rum.programs.mangohud;
in {
  options.rum.programs.mangohud = {
    enable = mkEnableOption "mangohud";

    package = mkPackageOption pkgs "mangohud" {nullable = true;};

    session.enable = mkEnableOption "start mangohud on any application that supports it";

    settings = mkOption {
      type = settingsType;
      default = {};
    };

    appSettings = mkOption {
      type = attrsOf settingsType;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    environment.sessionVariables = mkIf cfg.session.enable {
      MANGOHUD = 1;
      MANGOHUD_DLSYM = 1;
    };

    xdg.config.files =
      {
        "MangoHud/MangoHud.confg" = mkIf (cfg.settings != {}) {text = renderSettings cfg.settings;};
      }
      // pipe cfg.appSettings [
        (filterAttrs (_: value: value != {}))
        (mapAttrs' (name: value: nameValuePair "MangoHud/${name}.conf" {text = renderSettings value;}))
      ];
  };
}
