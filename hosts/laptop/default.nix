{ pkgs, ... }:

{
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
    ./screenpad.nix
  ];

  networking.hostName = "laptop";

  sops.secrets.smbcredentials = {
    mode = "0600";
    sopsFile = ./secrets.yaml;
  };

  base.enable = true;
  base.boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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
