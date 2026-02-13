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

    kernel.sysfs = {
      devices.system.cpu.intel_pstate.hwp_dynamic_boost = 1;
    };
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
      powerManagement.enable = true;
      powerManagement.finegrained = true;

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

  # powerManagement.powertop.enable = true;
  services = {
    power-profiles-daemon.enable = false;
    tuned.enable = true;
    upower.enable = true;
  };

  specialisation.battery-saver.configuration = {
    environment.etc."specialisation".text = "battery-saver";
    hardware.asus.battery.chargeUpto = mkForce 100;
    boot.kernel.sysfs.devices.system.cpu.intel_pstate.hwp_dynamic_boost = mkForce 0;
  };
}
