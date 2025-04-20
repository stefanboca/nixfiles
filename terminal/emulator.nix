{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.ghostty);
    installVimSyntax = true;
  };
}
