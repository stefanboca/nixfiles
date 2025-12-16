{
  config,
  lib,
  pkgs,
  ...
}: {
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
    algorithm = "lzo-rle";
    memoryPercent = 50;
  };

  powerManagement.powertop.enable = true;
  services = {
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          energy_performance_preference = "performance";
          energy_perf_bias = "performance";
        };
        battery = {
          energy_performance_preference = "power";
          energy_perf_bias = "power";
          turbo = "never";
        };
      };
    };
    power-profiles-daemon.enable = false;
    upower.enable = true;
  };

  specialisation.battery-saver.configuration = {
    environment.etc."specialisation".text = "battery-saver";
    hardware.asus.battery.chargeUpto = lib.mkForce 100;
  };
}
