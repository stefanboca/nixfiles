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
        gpu-screen-recorder # FIXME: until https://github.com/NixOS/nixpkgs/pull/485772 is merged

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
      # keep-sorted start block=true
      avahi = {
        enable = true;
        nssmdns4 = true;
      };
      geoclue2.enable = true;
      gnome.sushi.enable = true; # quick previewer for nautilus
      gvfs.enable = true; # userspace virtual filesystem
      noctalia-shell = {
        enable = true;
        package = pkgs.noctalia-shell; # taken from overlay
      };
      udisks2.enable = true; # dbus service for querying and manipulating storage devices
      # keep-sorted end
    };

    programs = {
      # keep-sorted start block=true
      evince.enable = true; # document viewer
      gnome-disks.enable = true; # udisk frontend
      gpu-screen-recorder.enable = true; # for noctalia screen recording plugin
      seahorse.enable = true; # manager for gnome keyring
      ssh = {
        askPassword = "${pkgs.openssh-askpass}/libexec/gtk-ssh-askpass";
        enableAskPassword = true;
      };
      # keep-sorted end
    };

    xdg = {
      autostart.enable = true;
      icons.enable = true;
      menus.enable = true;
      mime.enable = true;
    };
  };
}
