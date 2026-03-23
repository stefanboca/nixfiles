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
        "ctrl+space>r=reload_config"

        # splits / surfaces
        "ctrl+shift+k=clear_screen"
        "ctrl+space>==equalize_splits"
        "ctrl+space>ctrl+n=jump_to_prompt:1"
        "ctrl+space>ctrl+p=jump_to_prompt:-1"
        "ctrl+space>ctrl+t=prompt_surface_title"
        "ctrl+space>h=goto_split:left"
        "ctrl+space>j=goto_split:down"
        "ctrl+space>k=goto_split:up"
        "ctrl+space>l=goto_split:right"
        "ctrl+space>s=new_split:down"
        "ctrl+space>shift+l=toggle_readonly"
        "ctrl+space>shift+r=reset"
        "ctrl+space>v=new_split:right"
        "ctrl+space>x=close_surface"
        "ctrl+space>z=toggle_split_zoom"

        # tabs
        "ctrl+space>1=goto_tab:1"
        "ctrl+space>2=goto_tab:2"
        "ctrl+space>3=goto_tab:3"
        "ctrl+space>4=goto_tab:4"
        "ctrl+space>5=goto_tab:5"
        "ctrl+space>6=goto_tab:6"
        "ctrl+space>7=goto_tab:7"
        "ctrl+space>8=goto_tab:8"
        "ctrl+space>9=goto_tab:9"
        "ctrl+space>[=previous_tab"
        "ctrl+space>]=next_tab"
        "ctrl+space>ctrl+[=move_tab:-1"
        "ctrl+space>ctrl+]=move_tab:1"
        "ctrl+space>ctrl+x=close_tab"
        "ctrl+space>n=new_tab"

        # windows
        "ctrl+space>t=toggle_tab_overview"
        "ctrl+space>p=toggle_command_palette"
        "ctrl+space>ctrl+f=toggle_fullscreen"
        "ctrl+space>f=toggle_maximize"
        "ctrl+space>shift+n=new_window"
      ];
    };

    integrations.bat.enable = true;
  };
}
