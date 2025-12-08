{pkgs, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
    ./screenpad.nix
  ];

  networking.hostName = "laptop";

  base = {
    enable = true;
    appimage.enable = true;
    docs.extraMan.enable = true;
  };
  theming.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.printing = {
    enable = true;
    drivers = [pkgs.cnijfilter2];
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

  system.stateVersion = "26.05";
}
