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
    enableCosmic = lib.mkEnableOption "Enable Cosmic DE";
    enableGnome = lib.mkEnableOption "Enable Gnome DE";
    enableNiri = lib.mkEnableOption "Enable niri WM";
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

    programs.niri = lib.mkIf cfg.enableNiri {
      enable = true;
      package = pkgs.niri-unstable;
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
      ])
      ++ (lib.optionals cfg.enableNiri [
        xwayland-satellite-unstable
        waybar
        centerpiece
      ]);
  };
}
