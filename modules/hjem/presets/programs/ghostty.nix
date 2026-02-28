{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.ghostty;
in {
  options.presets.programs.ghostty = {
    enable = mkEnableOption "ghostty preset";
  };

  config.rum.programs.ghostty = mkIf cfg.enable {
    enable = true;

    settings = {
      # keep-sorted start
      auto-update = "off";
      background-blur = true;
      background-opacity = 0.5;
      config-file = "?dev";
      font-family = "Lilex";
      font-feature = "cv09,cv10,cv11,ss01,ss03";
      font-size = 10;
      gtk-tabs-location = "bottom";
      palette-generate = true;
      palette-harmonious = true;
      quit-after-last-window-closed = true;
      quit-after-last-window-closed-delay = "5m";
      scrollback-limit = 128 * 1024 * 1024; # 128 MB
      shell-integration-features = true;
      theme = "light:Catppuccin Latte,dark:Catppuccin Mocha";
      unfocused-split-opacity = 0.85;
      window-inherit-working-directory = true;
      window-padding-x = 0;
      window-padding-y = 0;
      window-theme = "ghostty";
      # keep-sorted start

      keybind = [
        "alt+t=toggle_tab_overview"
        "ctrl+shift+k=clear_screen"
        "ctrl+shift+backslash=new_split:right"
        "ctrl+shift+minus=new_split:down"
        "ctrl+shift+x=close_surface"

        "shift+up=goto_split:up"
        "shift+down=goto_split:down"
        "shift+left=goto_split:left"
        "shift+right=goto_split:right"
      ];
    };

    integrations.bat.enable = true;
  };
}
