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

      environment.systemPackages = with pkgs; [
        brightnessctl
        dconf-editor
      ];

      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "ghostty";
      };

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

      security.pam.services.swaylock = { };
      systemd.user.services = {
        niri-flake-polkit.enable = false;
        polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        swaylock = {
          description = "Swaylock";
          onSuccess = [ "unlock.target" ]; # If swaylock exits cleanly, unlock the session
          partOf = [ "lock.target" ]; # When lock.target is stopped, stops this too
          # Delay lock.target until this service is ready:
          before = [ "lock.target" ];
          wantedBy = [ "lock.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${lib.getExe pkgs.swaylock}";
            # If swaylock crashes, always restart it immediately:
            Restart = "on-failure";
            RestartSec = 0;
          };
        };
      };

      services = {
        # avahi.enable = true;
        # geoclue2.enable = true;
        gnome.sushi.enable = true; # quick previewer for nautilus
        systemd-lock-handler.enable = true; # add systemd user lock.target
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
        fuzzel # application launcher
        gnome-calculator # calculator
        gnome-font-viewer # font viewer
        loupe # image viewer
        mako # notification daemon
        nautilus # file explorer
        swayidle # idle management daemon
        totem # video player
        waybar # wayland bar
      ];
    })
  ];
}
