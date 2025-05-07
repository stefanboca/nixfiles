{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = lib.mkDefault [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets = {
      nix-access-tokens = { };
      ssh-extra-config = { };
    };
  };

  nix.extraOptions = ''
    !include ${config.sops.secrets.nix-access-tokens.path}
  '';

  programs.ssh.includes = [ config.sops.secrets.ssh-extra-config.path ];
}
