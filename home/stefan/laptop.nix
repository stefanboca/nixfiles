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

  dconf = {
    enable = true;
    # map screenpad touchscreen to correct display
    settings."org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = [
      "BOE"
      "0x0a8d"
      "0x00000000"
    ];
  };
}
