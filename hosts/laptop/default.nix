{ pkgs, ... }:

{
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  base.enable = true;
  base.boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  desktop = {
    enable = true;
    isLaptop = true;
    dm = "gdm";
    wm.enableGnome = true;
    wm.enableCosmic = true;
  };

  system.stateVersion = "25.11";
}
