{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop;
in
{
  imports = [
    ./dm.nix
    ./wm.nix
  ];

  options.desktop = {
    enable = lib.mkEnableOption "Enable the desktop environment module.";

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable laptop-specific settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: consider disabling these
    # systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

    # TODO: xdg portal integration w/ base system

    services.xserver.enable = false; # disable wayland

    fonts.enableDefaultPackages = true;
    fonts.fontconfig.enable = true;
    fonts.fontDir.enable = true;

    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      jack.enable = lib.mkDefault true;

      wireplumber = {
        extraConfig."10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.headset-roles" = [
              "hsp_hs"
              "hsp_ag"
              "hfp_hf"
              "hfp_ag"
            ];
          };
        };
      };
    };

    hardware = {
      bluetooth.enable = true;
      graphics.enable = true;
    };
    services.blueman.enable = true;

    systemd.user.services.mpris-proxy = lib.mkIf config.hardware.bluetooth.enable {
      description = "Mpris proxy";
      after = [
        "network.target"
        "sound.target"
      ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };

    services.thermald.enable = true;
    services.power-profiles-daemon.enable = lib.mkIf cfg.isLaptop false;
    services.tlp.enable = lib.mkIf cfg.isLaptop false;
    services.auto-cpufreq.enable = lib.mkIf cfg.isLaptop true;
    services.upower.enable = lib.mkIf cfg.isLaptop true;

    services.udev.extraRules = lib.concatStringsSep "\n" [
      # rules for allowing users in the video group to change the backlight brightness
      ''
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      ''
    ];
  };
}
