{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;

  source = config.catppuccin.sources.bat;
  themeName = "Catppuccin ${lib.toSentenceCase cfg.flavor}";

  cfg = config.catppuccin.programs.bat;
in {
  options.catppuccin.programs.bat = mkCatppuccinOption {name = "bat";};

  config.rum.programs.bat = lib.mkIf (cfg.enable && config.rum.programs.bat.enable) {
    flags = ["--theme='${themeName}'"];
    themes."${themeName}.tmTheme" = "${source}/${themeName}.tmTheme";
  };
}
