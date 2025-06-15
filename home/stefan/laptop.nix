{ pkgs, ... }:

{
  imports = [
    ./shared.nix
    ./sops.nix
  ];

  desktop = {
    enable = true;
    wm.enableNiri = true;
  };

  home.packages = with pkgs; [
    esphome
    blender
    calibre
    geogebra6
    musescore
    prusa-slicer
    rnote
    xournalpp
    zotero
  ];

  programs.obs-studio.enable = true;

  theming.enable = true;
  theming.colorscheme = "tokyonight-moon";

  dconf = {
    enable = true;
    settings = {
      # map screenpad touchscreen to correct display
      "org/gnome/desktop/peripherals/touchscreens/04f3:2f2a".output = [
        "BOE"
        "0x0a8d"
        "0x00000000"
      ];
      "org/gnome/mutter".experimental-features = [
        "autoclose-xwayland"
        "kms-modifiers"
        "scale-monitor-framebuffer"
        "variable-refresh-rate"
        "xwayland-native-scaling"
      ];
    };
  };
}
