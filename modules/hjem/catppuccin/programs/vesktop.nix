{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption mkFlavorName;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) toSentenceCase;

  themeName = "catppuccin-${cfg.flavor}-${cfg.accent}.theme";

  cfg = config.catppuccin.programs.vesktop;
in {
  options.catppuccin.programs.vesktop = mkCatppuccinOption {
    name = "vesktop";
    accentSupport = true;
  };

  config.rum.programs.vesktop = mkIf (cfg.enable && config.rum.programs.vesktop.enable) {
    vencord = {
      settings.enabledThemes = ["${themeName}.css"];
      themes."${themeName}" = ''
        /**
         * @name Catppuccin ${mkFlavorName cfg.flavor} (${toSentenceCase cfg.accent})
         * @author Catppuccin
         * @description 🎮 Soothing pastel theme for Discord
         * @website https://github.com/catppuccin/discord
        **/
        @import url("https://catppuccin.github.io/discord/dist/${themeName}.css");
      '';
    };
  };
}
