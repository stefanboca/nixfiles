{
  config,
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

    kernelParams = [
      # keep-sorted start
      "zswap.compressor=zstd"
      "zswap.enabled=1" # enables zswap
      "zswap.max_pool_percent=50" # maximum percentage of RAM that zswap is allowed to use
      "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
      # keep-sorted end
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [
      (pkgs.asus-nb-wmi-kernel-module.override {inherit (config.boot.kernelPackages) kernel;})
    ];

    kernel = {
      sysctl = {
        "vm.swappiness" = 60; # 60 is the default, but override tuned
      };
      sysfs = {
        devices.system.cpu.intel_pstate.hwp_dynamic_boost = 1;
      };
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

  powerManagement.enable = true;

  systemd.sleep.settings.Sleep = {
    MemorySleepMode = "deep";
  };
  services = {
    # keep-sorted start block=yes
    hardware.bolt.enable = true;
    power-profiles-daemon.enable = false;
    tuned = {
      enable = true;
      settings.dynamic_tuning = true;
    };
    upower.enable = true;
    # keep-sorted end
  };
}
