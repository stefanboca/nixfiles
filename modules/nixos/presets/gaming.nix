{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkForce mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.gaming;
in {
  options.presets.gaming = {
    enable = mkEnableOption "gaming preset";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gamemode
      prismlauncher
    ];

    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
      };
    };

    specialisation.gaming.configuration = {
      environment.etc."specialisation".text = "gaming";
      system.nixos.tags = ["gaming"];

      boot = {
        kernel.sysctl = {"vm.swappiness" = 10;};
        kernelParams = ["threadirqs"];
        kernelPackages = mkForce pkgs.linuxKernel.packages.linux_lqx;
      };

      security.pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "soft";
          value = "99999";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "hard";
          value = "99999";
        }
      ];

      hardware.nvidia.powerManagement.finegrained = mkForce false;

      services.pipewire = {
        jack.enable = true;
        extraConfig.pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [44100 48000 96000];
            "default.clock.quantum" = 128;
            "default.clock.min-quantum" = 16;
            "default.clock.max-quantum" = 1024;
          };
        };
      };
    };
  };
}
