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

      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services.hardware.bolt.enable = true;

  boot.kernel.sysctl = {
    # see www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  services = {
    power-profiles-daemon.enable = false;
    tuned = {
      enable = true;
      settings.dynamic_tuning = true;
    };
    upower.enable = true;
  };
}
