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
    fonts.fontconfig.enable = true;
    fonts.fontDir.enable = true;

    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      # jack.enable = true;

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

    systemd.user.services.mpris-proxy = lib.mkIf config.hardware.bluetooth.enable {
      description = "Mpris proxy";
      after = [
        "network.target"
        "sound.target"
      ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };

    services.power-profiles-daemon.enable = lib.mkIf cfg.isLaptop false;
    services.auto-cpufreq.enable = lib.mkIf cfg.isLaptop true;
    services.thermald.enable = true;

    services.udev.extraRules = lib.concatStringsSep "\n" [
      # rules for allowing users in the video group to change the backlight brightness
      ''
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      ''
    ];
  };
}
