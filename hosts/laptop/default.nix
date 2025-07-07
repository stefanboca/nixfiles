{
  config,
  lib,
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

  # TODO: remove on https://github.com/NixOS/nixpkgs/pull/419588/files
  security.pam.services = lib.mkIf config.security.polkit.enable {
    systemd-run0 = { };
  };

  system.stateVersion = "25.11";
}
