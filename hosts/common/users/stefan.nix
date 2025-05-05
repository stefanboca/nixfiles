{ config, pkgs, ... }:

{
  users.users.stefan = {
    description = "Stefan Boca";
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.stefan-pw.path;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../../home/stefan/keys/id_ed25519.pub)
    ];
  };

  sops.secrets.stefan-pw.neededForUsers = true;

  home-manager.users.stefan = import ../../../home/stefan/${config.networking.hostName}.nix;
}
