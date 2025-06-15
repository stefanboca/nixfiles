{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.wm;
in
{
  options.desktop.wm = {
    enableGnome = lib.mkEnableOption "Enable Gnome DE.";
    enableCosmic = lib.mkEnableOption "Enable Cosmic DE.";
  };

  config = {
    services = {
      xserver.xkb.options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";

      desktopManager = {
        gnome.enable = lib.mkIf cfg.enableGnome true;
        cosmic.enable = lib.mkIf cfg.enableCosmic true;
      };

      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };
    };

    xdg.portal.enable = true;

    environment.systemPackages =
      with pkgs;
      [ dconf-editor ]
      ++ (lib.optionals cfg.enableCosmic [
        cosmic-bg
      ])
      ++ (lib.optionals cfg.enableGnome [
        gnome-tweaks
        gnome-backgrounds
      ]);
  };
}
