{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) concatStringsSep;

  cfg = config.presets.desktop;
in {
  options.presets.desktop = {
    enable = mkEnableOption "desktop preset";
  };

  config = mkIf cfg.enable {
    presets.mime.enable = true;

    environment.systemPackages = [pkgs.brightnessctl pkgs.dconf-editor];

    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = false;
      };
      graphics.enable = true;
    };

    security.rtkit.enable = true;

    # help fix shutdown taking a long time
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "10s";
      DefaultTimeoutStartSec = "10s";
    };

    services = {
      accounts-daemon.enable = true; # used by dms
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;

        wireplumber.extraConfig.bluetoothEnhancements."monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.headset-roles" = ["a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
        };
      };
      udev.extraRules = concatStringsSep "\n" [
        # udevrules
        ''
          # allow users in the video group to change the backlight brightness and power
          ACTION=="add", SUBSYSTEM=="backlight", \
            RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
            RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness", \
            RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/bl_power", \
            RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/bl_power"
        ''
      ];
      xserver.xkb.options = "terminate:ctrl_alt_bksp,caps:ctrl_modifier";
    };

    # TODO: consider
    # xdg.autostart.enable = mkForce false;
  };
}
