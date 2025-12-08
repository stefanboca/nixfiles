{catppuccinLib}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;

  package = pkgs.catppuccin-papirus-folders.override {inherit (cfg.icon) accent flavor;};

  polarity =
    if cfg.icon.flavor == "latte"
    then "Light"
    else "Dark";

  cfg = config.catppuccin.misc.gtk;
in {
  options.catppuccin.misc.gtk = {
    icon = mkCatppuccinOption {
      name = "GTK modified Papirus icon theme";
      accentSupport = true;
    };
  };

  config = lib.mkIf (cfg.icon.enable && config.rum.misc.gtk.enable) {
    packages = [package];

    rum.misc.gtk.settings.icon-theme-name = "Papirus-${polarity}";
  };
}
