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

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      primeBatterySaverSpecialisation = true;

      # NOTE: temp fix for https://github.com/NixOS/nixpkgs/issues/467145
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      package =
        config.boot.kernelPackages.nvidiaPackages.beta
        // {
          open = config.boot.kernelPackages.nvidiaPackages.stable.open.overrideAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                (pkgs.fetchpatch {
                  name = "get_dev_pagemap.patch";
                  url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
                  hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
                })
              ];
          });
        };
    };
  };

  specialisation.battery-saver.configuration = {
    environment.etc."specialisation".text = "battery-saver";
    hardware.asus.battery.chargeUpto = lib.mkForce 100;
  };
}
