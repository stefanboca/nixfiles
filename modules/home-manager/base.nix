{ config, lib, ... }:

let
  cfg = config.base;
in
{
  options.base = {
    enable = lib.mkEnableOption "Enable base module";
  };

  config = lib.mkIf cfg.enable {
    home = {
      username = lib.mkDefault "stefan";
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
      stateVersion = lib.mkDefault "25.05";
      preferXdgDirectories = true;
      language.base = "en_US.UTF-8";
    };

    programs.home-manager = {
      enable = true;
      path = lib.mkForce "${config.home.homeDirectory}/data/nixfiles";
    };

    xdg.enable = true;
    fonts.fontconfig.enable = true;

    gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    # enable man pages
    manual = {
      html.enable = true;
      json.enable = lib.mkDefault true;
    };
    programs.man.generateCaches = false;
  };
}
