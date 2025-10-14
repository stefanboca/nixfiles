{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop.wm;

  # extract nm-connection-editor from networkmanagerapplet
  nm-connection-editor = pkgs.runCommand "nm-connection-editor" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.networkmanagerapplet}/bin/nm-connection-editor $out/bin/
  '';
in {
  options.desktop.wm = {
    enableCosmic = lib.mkEnableOption "Enable Cosmic DE";
    enableGnome = lib.mkEnableOption "Enable Gnome DE";
    enableNiri = lib.mkEnableOption "Enable niri WM";
  };

  config = lib.mkMerge [
    {
      services = {
        xserver.xkb.options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";
        libinput = {
          enable = true;
          touchpad.naturalScrolling = true;
        };
      };

      xdg.portal.enable = true;
      xdg.autostart.enable = lib.mkForce false;

      environment.systemPackages = with pkgs; [
        brightnessctl
        dconf-editor
      ];
    }

    (lib.mkIf cfg.enableGnome {
      services.desktopManager.gnome.enable = true;
      environment.systemPackages = with pkgs; [
        gnome-tweaks
        gnome-backgrounds
      ];
    })

    (lib.mkIf cfg.enableCosmic {
      services.desktopManager.cosmic.enable = true;
      environment.systemPackages = with pkgs; [
        cosmic-bg
      ];
    })

    (lib.mkIf cfg.enableNiri {
      xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      systemd.user.services = {
        niri-flake-polkit.enable = false;
        polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = ["graphical-session.target"];
          wants = ["graphical-session.target"];
          after = ["graphical-session.target"];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };

      services = {
        # avahi.enable = true;
        # geoclue2.enable = true;
        gnome.sushi.enable = true; # quick previewer for nautilus
        gvfs.enable = true; # userspace virtual filesystem
        udisks2.enable = true; # dbus service for querying and manipulating storage devices
      };
      programs = {
        dconf.enable = true;
        evince.enable = true; # document viewer
        file-roller.enable = true; # archive manager
        gnome-disks.enable = true; # udisk frontend
        seahorse.enable = true; # manager for gnome keyring
      };

      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        baobab # disk usage analyzer
        decibels # audio player
        gnome-calculator # calculator
        gnome-font-viewer # font viewer
        gnome-power-manager # view battery and power statistics
        loupe # image viewer
        nautilus # file explorer
        playerctl # utility for controlling mpris media players
        totem # video player
        xwayland-satellite-unstable

        nm-connection-editor
      ];
    })
  ];
}
