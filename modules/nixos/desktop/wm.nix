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

    xdg.portal.enable = true;

    programs.niri = lib.mkIf cfg.enableNiri {
      enable = true;
      package = pkgs.niri-unstable;
    };

    systemd.user.services = lib.mkIf cfg.enableNiri {
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
    };

    environment.systemPackages =
      with pkgs;
      [
        brightnessctl
        dconf-editor
      ]
      ++ (lib.optionals cfg.enableCosmic [
        dconf-editor
        cosmic-bg
      ])
      ++ (lib.optionals cfg.enableGnome [
        gnome-tweaks
        gnome-backgrounds
      ])
      ++ (lib.optionals cfg.enableNiri [
        fuzzel
        mako
        swaybg
        swayidle
        swaylock
        waybar
        xwayland-satellite-unstable
      ]);
  };
}
