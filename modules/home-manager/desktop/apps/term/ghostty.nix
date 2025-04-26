{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.ghostty);
      installVimSyntax = true;
      installBatSyntax = true;

      settings = {
        auto-update = "off";
        shell-integration-features = true;
        image-storage-limit = 128 * 1024 * 1024; # 128 MB
        scrollback-limit = 128 * 1024 * 1024; # 128 MB

        window-inherit-working-directory = true;
        window-theme = "ghostty";
        window-decoration = "none";
        gtk-tabs-location = "bottom";
        window-padding-x = 0;
        window-padding-y = 0;

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
  };
}
