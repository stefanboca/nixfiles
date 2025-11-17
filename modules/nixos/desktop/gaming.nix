{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop.gaming;

  steam-run-libs = pkgs.runCommand "steam-run-libs" {} ''
    mkdir $out
    ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib
  '';
in {
  options.desktop.gaming = {
    enable = lib.mkEnableOption "Enable gaming.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gamemode
      prismlauncher
    ];

    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
      };

      nix-ld = {
        enable = true;
        libraries = [steam-run-libs];
      };
    };

    specialisation.gaming.configuration = {
      environment.etc."specialisation".text = "gaming";
      system.nixos.tags = ["gaming"];

      boot = {
        kernel.sysctl = {"vm.swappiness" = 10;};
        kernelParams = ["threadirqs"];
        kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_lqx;
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

      hardware.nvidia.powerManagement.finegrained = lib.mkForce false;

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
