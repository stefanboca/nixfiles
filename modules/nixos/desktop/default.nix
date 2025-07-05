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
    fonts = {
      enableDefaultPackages = true;
      fontconfig.enable = true;
      fontDir.enable = true;
    };

    hardware = {
      bluetooth.enable = true;
      graphics.enable = true;
    };

    security.rtkit.enable = true;

    # fix shutdown taking a long time
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
    '';

    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        alsa.support32Bit = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
        # jack.enable = lib.mkDefault true;

        wireplumber.extraConfig.bluetoothEnhancements."monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.headset-roles" = [
            "a2dp_sink"
            "a2dp_source"
            "bap_sink"
            "bap_source"
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
      thermald.enable = true;
      power-profiles-daemon.enable = true;
      # tlp.enable = lib.mkIf cfg.isLaptop false;
      # auto-cpufreq.enable = lib.mkIf cfg.isLaptop true;
      upower.enable = lib.mkIf cfg.isLaptop true;

      udev.extraRules = lib.concatStringsSep "\n" [
        ''
          # allow users in the video group to change the backlight brightness and power
          ACTION=="add", SUBSYSTEM=="backlight", \
            RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
            RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness", \
            RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/bl_power", \
            RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/bl_power"
        ''
      ];
    };
  };
}
