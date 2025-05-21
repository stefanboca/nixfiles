{ pkgs, ... }:

{
  nix-plugins = pkgs.nix-plugins.overrideAttrs (_: {
    buildInputs = with pkgs; [
      nix
      boost
    ];
    patches = [ ./nix-plugins.patch ];
  });
}
