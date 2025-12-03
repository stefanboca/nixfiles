{
  config,
  lib,
  ...
}: let
  cfg = config.base;
in {
  options.base = {
    enable = lib.mkEnableOption "Enable base module";
  };

  config = lib.mkIf cfg.enable {
    home = {
      username = lib.mkDefault "stefan";
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
      stateVersion = lib.mkDefault "26.05";
      preferXdgDirectories = true;
      language.base = "en_US.UTF-8";
    };

    fonts.fontconfig.enable = false;

    gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    programs.man.enable = false;
  };
}
