{
  config,
  lib,
  ...
}: let
  cfg = config.desktop.wm;
in {
  options.desktop.wm.enableGnome = lib.mkEnableOption "Gnome DE";

  config = lib.mkIf cfg.enableGnome {
    dconf = {
      enable = true;
      settings."org/gnome/mutter".experimental-features = ["autoclose-xwayland" "kms-modifiers" "scale-monitor-framebuffer" "variable-refresh-rate" "xwayland-native-scaling"];
    };
  };
}
