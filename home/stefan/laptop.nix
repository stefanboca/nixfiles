{ config, pkgs, ... }:

{
  imports = [
    ./shared.nix
    ./sops.nix
  ];

  desktop.enable = true;

  home.packages =
    with pkgs;
    [
      esphome
    ]
    ++ (builtins.map (pkg: config.lib.nixGL.wrap pkg) [
      blender
      geogebra6
      helvum
      jetbrains.idea-community
      musescore
      prusa-slicer
      rnote
    ]);

  programs.obs-studio = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.obs-studio;
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
