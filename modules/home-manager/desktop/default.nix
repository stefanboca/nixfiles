{ config, lib, ... }:

let
  cfg = config.desktop;
in
{
  imports = [
    ./apps
    ./wm
  ];

  options.desktop = {
    enable = lib.mkEnableOption "Enable Desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps.enable = true;
  };
}
