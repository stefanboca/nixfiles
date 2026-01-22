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
      packages = with pkgs; [
        # keep-sorted start
        fira-code
        ibm-plex
        inter
        lilex
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-color-emoji
        open-sans
        # keep-sorted end
      ];
    };

    catppuccin.sddm = {
      font = "Open Sans";
      fontSize = "11";
    };
  };
}
