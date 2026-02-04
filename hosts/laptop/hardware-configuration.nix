{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkForce;
in {
  boot = {
    loader = {
      limine = {
        enable = true;
        secureBoot.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = ["thunderbolt" "vmd" "nvme" "uas" "rtsx_pci_sdmmc"];
    initrd.kernelModules = [];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [
      (pkgs.asus-nb-wmi-kernel-module.override {inherit (config.boot.kernelPackages) kernel;})
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  hardware = {
    enableRedistributableFirmware = true;

    asus.battery = {
      chargeUpto = 80;
      enableChargeUptoScript = true;
    };

    intelgpu.driver = "xe";

    nvidia = {
      open = true;
      powerManagement = {
        enable = false;
        finegrained = true;
      };
      dynamicBoost.enable = false;

      nvidiaSettings = false;

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      primeBatterySaverSpecialisation = true;

      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services.hardware.bolt.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  powerManagement.powertop.enable = true;
  services = {
    autocpu = {
      enable = true;
      package = pkgs.autocpu; # use package from overlay
      settings = {
        upower_battery_path = "/org/freedesktop/UPower/devices/battery_BAT0";
        on_battery = "powersave";
        on_wallpower = "performance";

        presets = {
          powersave = {
            epp = "power";
            hwp_dynamic_boost = false;
            no_turbo = true;
            scaling_governor = "powersave";
          };

          balanced = {
            epp = "default";
            hwp_dynamic_boost = false;
            no_turbo = true;
            scaling_governor = "powersave";
          };

          performance = {
            hwp_dynamic_boost = true;
            no_turbo = false;
            scaling_governor = "performance";
          };
        };
      };
    };
    power-profiles-daemon.enable = false;
    upower.enable = true;
  };

  specialisation.battery-saver.configuration = {
    environment.etc."specialisation".text = "battery-saver";
    hardware.asus.battery.chargeUpto = mkForce 100;
  };
}
