{ pkgs, ... }:

{
  imports = [
    ./users/root.nix
    ./users/stefan.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  nix.channel.enable = false;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;
}
