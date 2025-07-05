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
      services.systemd-lock-handler.enable = true;
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

      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        fuzzel
        mako
        swaybg
        swayidle
        swaylock
        waybar
      ];
    })
  ];
}
