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
    enableCosmic = lib.mkEnableOption "Enable Gnome DE.";
  };

  config = {
    services = {
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
