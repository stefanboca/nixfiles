{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.fonts;
in {
  options.presets.fonts = {
    enable = mkEnableOption "fonts preset";
  };

  config = mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = ["Lilex"];
          serif = ["Noto Serif"];
          sansSerif = ["Open Sans"];
          emoji = ["Noto Color Emoji"];
        };
      };
      packages = with pkgs; [lilex noto-fonts open-sans noto-fonts-color-emoji ibm-plex inter fira-code];
    };

    catppuccin.sddm = {
      font = "Open Sans";
      fontSize = "11";
    };
  };
}
