{ pkgs, ... }:

{
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  sops.secrets.smbcredentials = {
    mode = "0600";
    sopsFile = ./secrets.yaml;
  };

  base.enable = true;
  base.boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  desktop = {
    enable = true;
    isLaptop = true;
    dm = "gdm";
    wm = {
      enableGnome = true;
      enableCosmic = true;
      enableNiri = true;
    };
  };

  system.stateVersion = "25.11";
}
