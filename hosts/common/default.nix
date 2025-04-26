{ pkgs, ... }:

{
  imports = [
    ./users/root.nix
    ./users/stefan.nix
  ];

  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;
}
