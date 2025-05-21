{ pkgs, ... }:

{
  imports = [
    ./users/root.nix
    ./users/stefan.nix
    (builtins.extraBuiltins.readSops ./secrets.nix)
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      nix-secrets-common = {
        sopsFile = ./secrets.nix;
      };
    };
  };

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;
}
