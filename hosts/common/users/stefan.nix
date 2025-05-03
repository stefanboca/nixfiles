{ config, pkgs, ... }:

{
  users.users.stefan = {
    description = "Stefan Boca";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
    ];
    password = "temporarypassword"; # FIXME:

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../../home/stefan/keys/ssh.pub)
    ];
  };

  home-manager.users.stefan = import ../../../home/stefan/${config.networking.hostName}.nix;
}
