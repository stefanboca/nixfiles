{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;

  source = config.catppuccin.sources.eza;

  cfg = config.catppuccin.programs.eza;
in {
  options.catppuccin.programs.eza = mkCatppuccinOption {
    name = "eza";
    accentSupport = true;
  };

  config = lib.mkIf cfg.enable {
    xdg.config.files."eza/theme.yml".source = "${source}/${cfg.flavor}/catppuccin-${cfg.flavor}-${cfg.accent}.yml";
  };
}
