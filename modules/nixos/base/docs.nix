{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.base.docs;
in {
  options.base.docs = {
    enable = lib.mkEnableOption "Enable documentation config." // {default = true;};
    extraMan.enable = lib.mkEnableOption "Enable extra man pages.";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      documentation = {
        man = {
          generateCaches = true;
          man-db.enable = false;
          mandoc.enable = true;
        };
      };
    }
    (lib.mkIf cfg.extraMan.enable {
      environment.systemPackages = [
        pkgs.man-pages
        pkgs.man-pages-posix
      ];
      documentation.dev.enable = true;
    })
  ]);
}
