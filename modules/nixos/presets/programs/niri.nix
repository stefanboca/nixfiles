{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.presets.programs.niri;
in {
  options.presets.programs.niri = {
    enable = mkEnableOption "stefan preset";

    xwayland-satellite.package = mkPackageOption pkgs "xwayland-satellite-unstable" {nullable = true;};
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
    };

    environment.systemPackages = mkMerge [
      (with pkgs; [
        adwaita-icon-theme
        baobab # disk usage analyzer
        decibels # audio player
        file-roller # archive-manager
        gnome-calculator # calculator
        gnome-font-viewer # font viewer
        gnome-power-manager # view battery and power statistics
        loupe # image viewer
        nautilus # file explorer
        playerctl # utility for controlling mpris media players
        totem # video player

        (pkgs.onlyBin pkgs.networkmanagerapplet)
      ])
      (mkIf (cfg.xwayland-satellite.package != null) [cfg.xwayland-satellite.package])
    ];

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    fonts.enableDefaultPackages = true;

    security.soteria.enable = true;

    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
      };
      geoclue2.enable = true;
      gnome.sushi.enable = true; # quick previewer for nautilus
      gvfs.enable = true; # userspace virtual filesystem
      udisks2.enable = true; # dbus service for querying and manipulating storage devices
    };

    programs = {
      evince.enable = true; # document viewer
      gnome-disks.enable = true; # udisk frontend
      seahorse.enable = true; # manager for gnome keyring
    };

    xdg = {
      autostart.enable = true;
      icons.enable = true;
      menus.enable = true;
      mime.enable = true;
    };
  };
}
