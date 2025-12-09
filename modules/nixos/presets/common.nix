{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool str;

  cfg = config.presets.common;
in {
  options.presets.common = {
    enable = mkEnableOption "common preset";

    isLaptop = mkOption {
      type = bool;
      default = false;
      description = "Enable laptop-specific settings.";
    };

    primaryUser = mkOption {
      type = str;
      default = "stefan";
    };
  };

  config = mkIf cfg.enable {
    presets = {
      fonts.enable = true;
      minimal.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      evtest
      fatresize
      ffmpeg
      fzf
      git
      gnumake
      imagemagick
      jq
      libinput
      man-pages
      man-pages-posix
      wev
      # keep-sorted end
    ];

    boot.plymouth.enable = true;

    programs = {
      nh = {
        enable = true;
        flake = "/home/${cfg.primaryUser}/src/nixfiles";
      };
      # TODO: test remove steam-run-libs.
      nix-ld = {
        enable = true;
        libraries = [
          (pkgs.runCommand "steam-run-libs" {} ''mkdir $out; ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib'')
        ];
      };
    };

    documentation = {
      dev.enable = true;
      man.generateCaches = true;
    };

    powerManagement.powertop.enable = mkIf cfg.isLaptop true;
    services = {
      upower.enable = mkIf cfg.isLaptop true;
      power-profiles-daemon.enable = mkIf cfg.isLaptop false;
      auto-cpufreq = mkIf cfg.isLaptop {
        enable = true;
        settings = {
          charger = {
            energy_perf_bias = "performance";
          };
          battery = {
            energy_performance_preference = "power";
            energy_perf_bias = "power";
            turbo = "never";
          };
        };
      };
    };
  };
}
