{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) getBin mapAttrsToList;
  inherit (lib.generators) toDconfINI;
  inherit (lib.lists) flatten;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrs bool listOf str;

  mkAllLocks = settings:
    flatten (mapAttrsToList (k: v: mapAttrsToList (k': _: "/${k}/${k'}") v) settings);

  keyfile = pkgs.writeTextDir "dconf-keyfiles" (toDconfINI cfg.settings);
  locks = pkgs.writeTextDir "locks/dconf-locks" (
    concatStringsSep "\n" (
      if cfg.lockAll
      then mkAllLocks cfg.settings
      else cfg.locks
    )
  );

  keyfileDir = pkgs.symlinkJoin {
    name = "hjem-generated-dconf-keyfiles";
    paths = [keyfile locks];
  };

  dconfDb = pkgs.runCommand "dconf-db" {nativeBuildInputs = [(getBin pkgs.dconf)];} "dconf compile $out ${keyfileDir}";

  cfg = config.rum.misc.dconf;
in {
  options.rum.misc.dconf = {
    enable = mkEnableOption "dconf";

    settings = mkOption {
      type = attrs;
      default = {};
    };

    locks = mkOption {
      type = listOf str;
      default = [];
    };

    lockAll = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    xdg.config.files."dconf/hjem" = {source = dconfDb;};
  };
}
