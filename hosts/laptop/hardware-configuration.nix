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
      ((pkgs.asus-nb-wmi-kernel-module.override {inherit (config.boot.kernelPackages) kernel;}).overrideAttrs (_: {patches = [./0001-screenpad-keys.patch];}))
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  hardware = {
    asus.battery = {
      chargeUpto = 80;
      enableChargeUptoScript = true;
    };

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = true;

      # Whether to enable dynamic Boost balances power between the CPU and the
      # GPU for improved performance on supported laptops using the
      # nvidia-powerd daemon. For more information, see the NVIDIA docs, on
      # Chapter 23. Dynamic Boost on Linux.
      dynamicBoost.enable = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.beta;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      primeBatterySaverSpecialisation = true;
    };

    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  specialisation.battery-saver.configuration = {
    environment.etc."specialisation".text = "battery-saver";
    hardware.asus.battery.chargeUpto = lib.mkForce 100;
    hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false; # TODO: upstream this
  };
}
