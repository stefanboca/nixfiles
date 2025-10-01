{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.base.extraMan;
in {
  options.base.extraMan = {
    enable = lib.mkEnableOption "Enable extra man pages.";
  };

  config = lib.mkMerge [
    {
      documentation.man = {
        generateCaches = true;
        man-db.enable = false;
        mandoc.enable = true;
      };
    }
    (lib.mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.man-pages
        pkgs.man-pages-posix
      ];
      documentation.dev.enable = true;
    })
  ];
}
