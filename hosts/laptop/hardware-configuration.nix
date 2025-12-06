{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    initrd.availableKernelModules = ["thunderbolt" "vmd" "nvme" "uas" "rtsx_pci_sdmmc"];
    initrd.kernelModules = [];
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

  specialisation.battery-saver.configuration = {
    environment.etc."specialisation".text = "battery-saver";
    hardware.asus.battery.chargeUpto = lib.mkForce 100;
  };
}
