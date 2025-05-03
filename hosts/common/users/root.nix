{ config, pkgs, ... }:

{
  users.users.root = {
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.root-pw.path;

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../../home/stefan/keys/ssh.pub)
    ];
  };

  sops.secrets.root-pw.neededForUsers = true;
}
