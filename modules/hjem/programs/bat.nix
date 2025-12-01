{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) listOf str path;
  inherit (lib.strings) concatLines;

  cacheSource = pkgs.runCommand "bat-cache-source" {} ''
    mkdir -p $out/{syntaxes,themes}
    ${concatLines (map (p: "ln -s ${p} $out/syntaxes/${baseNameOf p}") cfg.syntaxes)}
    ${concatLines (map (p: "ln -s ${p} $out/themes/${baseNameOf p}") cfg.themes)}
    chmod -R a+rX $out
  '';

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
      type = listOf path;
      default = [];
    };

    themes = mkOption {
      type = listOf path;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    xdg.config.files."bat/config".text = mkIf (cfg.flags != []) (concatLines cfg.flags);
    xdg.cache.files."bat".source = cache;
  };
}
