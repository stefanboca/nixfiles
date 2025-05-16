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

      xserver.desktopManager.gnome.enable = lib.mkIf cfg.enableGnome true;
      desktopManager.cosmic.enable = lib.mkIf cfg.enableCosmic true;

      libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
    };

    environment.systemPackages =
      [ pkgs.dconf-editor ]
      ++ (lib.optionals cfg.enableCosmic [
        pkgs.cosmic-bg
      ])
      ++ (lib.optionals cfg.enableGnome [
        pkgs.gnome-tweaks
        pkgs.gnome-backgrounds
      ]);
  };
}
