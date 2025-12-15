{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.misc.gtk;
in {
  options.presets.misc.gtk = {
    enable = mkEnableOption "gtk preset";
  };

  config = mkIf cfg.enable {
    rum.misc.gtk = {
      enable = true;
      settings.application-prefer-dark-theme = true;
    };

    rum.misc.dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}
