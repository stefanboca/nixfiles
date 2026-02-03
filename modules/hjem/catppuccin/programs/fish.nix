{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (lib.modules) mkIf;

  source = config.catppuccin.sources.fish;
  themeName = "Catppuccin ${lib.toSentenceCase cfg.flavor}";

  cfg = config.catppuccin.programs.fish;
in {
  options.catppuccin.programs.fish = mkCatppuccinOption {name = "fish";};

  config = mkIf (cfg.enable && config.rum.programs.fish.enable) {
    xdg.config.files."fish/themes/${themeName}.theme".source = "${source}/${themeName}.theme";

    rum.programs.fish.config =
      # fish
      ''
        status is-interactive && fish_config theme choose "${themeName}"
      '';
  };
}
