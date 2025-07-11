{
  pkgs,
  ...
}:

{
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
    ./screenpad.nix
  ];

  networking.hostName = "laptop";
  networking.networkmanager.dns = "dnsmasq";

  sops.secrets.smbcredentials = {
    sopsFile = ./secrets.yaml;
  };

  base.enable = true;
  theming.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  base = {
    appimage.enable = true;
  };

  desktop = {
    enable = true;
    isLaptop = true;
    dm = "sddm";
    wm.enableNiri = true;
    gaming.enable = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  system.stateVersion = "25.11";
}
