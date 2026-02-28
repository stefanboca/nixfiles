{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.strings) getName getVersion makeBinPath;
  inherit (lib.types) listOf package;

  wrappedPackage = pkgs.symlinkJoin {
    name = "${getName cfg.package}-wrapped-${getVersion cfg.package}";
    paths = [cfg.package];
    preferLocalBuild = true;
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      wrapProgram $out/bin/zeditor \
        --suffix PATH : ${makeBinPath cfg.extraPackages}
    '';
  };

  cfg = config.rum.programs.zed-editor;
in {
  options.rum.programs.zed-editor = {
    enable = mkEnableOption "zed-editor";

    package = mkPackageOption pkgs "zed-editor" {};

    extraPackages = mkOption {
      type = listOf package;
    };
  };

  config = mkIf cfg.enable {
    packages = [wrappedPackage];
  };
}
