{ pkgs, ... }:

{
  tombi = pkgs.callPackage ./tombi.nix { };
}
