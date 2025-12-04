{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.strings) concatLines;
  inherit (lib.types) attrsOf listOf path str;

  mkCachePaths = root:
    mapAttrsToList (name: value: {
      name = "${root}/${name}";
      path = value;
    });

  cacheSource = pkgs.linkFarm "bat-cache-source" (
    (mkCachePaths "syntaxes" cfg.syntaxes) ++ (mkCachePaths "themes" cfg.themes)
  );

  cache = pkgs.runCommand "bat-cache" {} ''
    ${getExe cfg.package} cache --build --source ${cacheSource} --target $out
  '';

  cfg = config.rum.programs.bat;
in {
  options.rum.programs.bat = {
    enable = mkEnableOption "bat";

    package = mkPackageOption pkgs "bat" {nullable = true;};

    flags = mkOption {
      type = listOf str;
      default = [];
    };

    syntaxes = mkOption {
      type = attrsOf path;
      default = {};
    };

    themes = mkOption {
      type = attrsOf path;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    xdg.config.files."bat/config".text = mkIf (cfg.flags != []) (concatLines cfg.flags);
    xdg.cache.files."bat".source = cache;
  };
}
