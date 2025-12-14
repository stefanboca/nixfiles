{catppuccinLib}: {
  config,
  lib,
  name,
  pkgs,
  ...
}: let
  inherit (catppuccinLib) mkCatppuccinOption;
  inherit (catppuccinLib.types) accent;
  inherit (lib.modules) mkBefore mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum int mergeTypes;

  source = config.catppuccin.sources.cursors;

  themeName = "catppuccin-${cfg.flavor}-${cfg.accent}-cursors";

  # "dark" and "light" can be used alongside the regular accents
  cursorAccentType = mergeTypes accent (enum ["dark" "light"]);

  defaultIndexThemePackage = pkgs.writeTextFile {
    name = "index.theme";
    destination = "/share/icons/default/index.theme";
    # Set name in icons theme, for compatibility with AwesomeWM etc. See:
    # https://github.com/nix-community/home-manager/issues/2081
    # https://wiki.archlinux.org/title/Cursor_themes#XDG_specification
    text = ''
      [Icon Theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=${themeName}
    '';
  };

  niriConfigFile =
    pkgs.writeText "niri-catppuccin-cursors.kdl"
    # kdl
    ''
      cursor {
        xcursor-theme "${themeName}"
        xcursor-size ${toString cfg.size}
      }
    '';

  cfg = config.catppuccin.misc.cursors;
in {
  options.catppuccin.misc.cursors =
    mkCatppuccinOption {
      name = "pointer cursors";
      useGlobalEnable = false;
    }
    // {
      accent = mkOption {
        type = cursorAccentType;
        default = config.catppuccin.accent;
        description = "Catppuccin accent for pointer cursors";
      };

      size = mkOption {
        type = int;
        default = 32;
        example = 64;
        description = "The cursor size.";
      };

      integrations = {
        gtk.enable = mkEnableOption "catppuccin cursors integration with gtk";
        niri.enable = mkEnableOption "catppuccin cursors integration with niri";
      };
    };

  config = mkIf cfg.enable {
    packages = [source defaultIndexThemePackage];

    environment.sessionVariables = mkIf (!cfg.integrations.niri.enable) {
      # niri sets these automatically
      XCURSOR_THEME = mkDefault themeName;
      XCURSOR_SIZE = mkDefault cfg.size;
    };

    # TODO: _somehow_ get these into dconf (/org/gnome/desktop/interface)
    rum.misc.gtk.settings = mkIf (cfg.integrations.gtk.enable && config.rum.misc.gtk.enable) {
      cursor-theme-name = themeName;
      cursor-theme-size = cfg.size;
    };

    rum.desktops.niri.config = mkIf (cfg.integrations.niri.enable && config.rum.desktops.niri.enable) (mkBefore
      # kdl
      ''
        include "${niriConfigFile}"
      '');
  };
}
