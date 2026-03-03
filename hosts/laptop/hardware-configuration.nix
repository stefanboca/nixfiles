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

      # FIXME: https://github.com/NixOS/nixpkgs/pull/490123
      package = let
        base = config.boot.kernelPackages.nvidiaPackages.beta;
        cachyos-nvidia-patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
          sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
        };
      in
        base // {open = base.open.overrideAttrs (prevAttrs: {patches = (prevAttrs.patches or []) ++ [cachyos-nvidia-patch];});};
    };
  };

  services.hardware.bolt.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
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
