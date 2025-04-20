{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.ghostty);
    installVimSyntax = true;
    installBatSyntax = true;

    # TODO: themes

    settings = {
      auto-update = "off";
      shell-integration-features = true;
      image-storage-limit = 128 * 1024 * 1024; # 128 MB
      scrollback-limit = 128 * 1024 * 1024; # 128 MB

      theme = "tokyonight_moon";
      window-inherit-working-directory = true;
      window-theme = "ghostty";
      window-decoration = "none";
      gtk-tabs-location = "bottom";
      window-padding-x = 0;
      window-padding-y = 0;
      font-size = 10;
      font-family = "lilex";
      font-feature = [
        "cv09"
        "cv10"
        "cv11"
        "ss01"
        "ss03"
      ];

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
  };
}
