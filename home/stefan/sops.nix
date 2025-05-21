{
  config,
  lib,
  pkgs,
  ...
}:

{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = lib.mkDefault [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets = {
      nix-access-tokens = { };
      ssh-extra-config = { };
      atuin-key.path = "${config.xdg.dataHome}/atuin/key";
    };
  };

  nix = {
    settings.plugin-files = "${pkgs.nix-plugins}/lib/nix/plugins";
    settings.extra-builtins-file = [ ../../modules/nix/extra-builtins.nix ];
    extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';
  };

  programs.ssh.includes = [ config.sops.secrets.ssh-extra-config.path ];
}
