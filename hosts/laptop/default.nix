{ ... }:

{
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  base.enable = true;
  base.boot.enable = true;

  desktop = {
    enable = true;
    isLaptop = true;
    dm = "cosmic-greeter";
    wm.enableGnome = true;
    wm.enableCosmic = true;
  };

  system.stateVersion = "25.05";
}
