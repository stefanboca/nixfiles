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
      rm $out/libexec/zed-editor
      makeWrapper $out/libexec/.zed-editor-wrapped $out/libexec/zed-editor \
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
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = [wrappedPackage];

    rum.programs.zed-editor.extraPackages = [pkgs.nodejs];
  };
}
