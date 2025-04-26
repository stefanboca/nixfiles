{ config, pkgs, ... }:

{
  imports = [ ./shared.nix ];

  desktop.enable = true;

  home.packages = builtins.map (pkg: (config.lib.nixGL.wrap pkg)) [
    pkgs.blender
    pkgs.geogebra6
    pkgs.jetbrains.idea-community
    pkgs.musescore
    pkgs.prusa-slicer
    pkgs.rnote
  ];

  programs.obs-studio = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.obs-studio);
  };

  theming.enable = true;
  theming.colorscheme = "tokyonight-moon";
}
