{ config, pkgs, ... }:

{
  users.users.gabe = {
    description = "Stefan Boca";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];

  };

  home-manager.users.stefan = import ../../../home/stefan/${config.networking.hostName}.nix;
}
