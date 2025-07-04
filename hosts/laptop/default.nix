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

  sops.secrets.smbcredentials = {
    mode = "0600";
    sopsFile = ./secrets.yaml;
  };

  base.enable = true;
  base.boot.enable = true;

  theming.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  desktop = {
    enable = true;
    isLaptop = true;
    dm = "sddm";
    wm = {
      enableGnome = true;
      enableNiri = true;
    };
  };

  # TODO: remove on https://github.com/NixOS/nixpkgs/pull/419588/files
  security.pam.services = lib.mkIf config.security.polkit.enable {
    systemd-run0 = { };
  };

  system.stateVersion = "25.11";
}
