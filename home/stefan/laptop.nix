{
  config,
  lib,
  pkgs,
  ...
}:

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
    # calibre
    freecad
    geogebra6
    # musescore
    prusa-slicer
    rnote
    # xournalpp
    # zotero
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/prusaslicer" = "PrusaSlicer.desktop";
  };

  programs.obs-studio.enable = true;

  theming.enable = true;
  theming.colorscheme = "tokyonight-moon";

  programs.niri.settings = {
    input.tablet.map-to-output = "eDP-1";
    input.touch.map-to-output = "eDP-1";
    binds = with config.lib.niri.actions; {
      XF86MonBrightnessUp = lib.mkForce {
        allow-when-locked = true;
        action = spawn [
          "sh"
          "-c"
          "brightnessctl -d intel_backlight set +10%; brightnessctl -d asus_screenpad set +10%"
        ];
      };
      XF86MonBrightnessDown = lib.mkForce {
        allow-when-locked = true;
        action = spawn [
          "sh"
          "-c"
          "brightnessctl -d intel_backlight set 10%-; brightnessctl -d asus_screenpad set 10%-"
        ];
      };
    };
  };

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
