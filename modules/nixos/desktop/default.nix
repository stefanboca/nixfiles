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

    services = {
      pulseaudio.enable = false;
      pipewire = {
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
      blueman.enable = true;
      thermald.enable = true;
      power-profiles-daemon.enable = lib.mkIf cfg.isLaptop false;
      tlp.enable = lib.mkIf cfg.isLaptop false;
      auto-cpufreq.enable = lib.mkIf cfg.isLaptop true;
      upower.enable = lib.mkIf cfg.isLaptop true;

      udev.extraRules = lib.concatStringsSep "\n" [
        # rules for allowing users in the video group to change the backlight brightness
        ''
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="asus_screenpad", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="asus_screenpad", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
        ''
      ];
    };

    # TODO: is this actually needed?
    # systemd.user.services.mpris-proxy = lib.mkIf config.hardware.bluetooth.enable {
    #   description = "Mpris proxy";
    #   after = [
    #     "network.target"
    #     "sound.target"
    #   ];
    #   wantedBy = [ "default.target" ];
    #   serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    # };
  };
}
