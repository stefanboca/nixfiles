{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.desktop;
in {
  options.desktop.enable = lib.mkEnableOption "Enable Desktop configuration" // {default = osConfig.desktop.enable or false;};

  config = lib.mkIf cfg.enable {
    xdg.mime.enable = false;
  };
}
