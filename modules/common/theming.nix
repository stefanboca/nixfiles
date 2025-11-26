{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.theming;

  catppuccinLib = import "${inputs.catppuccin}/modules/lib" {inherit config lib pkgs;};

  mkFontOpt = typeName:
    mkOption {
      description = "Settings for the ${typeName} font";
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Display name of the ${typeName} font";
          };
          package = mkOption {
            type = types.package;
            description = "The package providing the ${typeName} font";
          };
          features = mkOption {
            type = types.listOf types.str;
            description = "Features to use for the ${typeName} font";
            default = [];
          };
        };
      };
    };
in {
  options.theming = {
    enable = mkEnableOption "Enable system theming";

    flavor = lib.mkOption {
      type = catppuccinLib.types.flavor;
      default = "mocha";
      description = "Global Catppuccin flavor";
    };

    accent = lib.mkOption {
      type = catppuccinLib.types.accent;
      default = "teal";
      description = "Global Catppuccin accent";
    };

    fonts = mkOption {
      description = "Font settings";
      type = types.submodule {
        options = {
          monospace = mkFontOpt "monospace";
          serif = mkFontOpt "serif";
          sansSerif = mkFontOpt "sans-serif";
          emoji = mkFontOpt "emoji";

          sizes = mkOption {
            description = "Font size settings";
            type = types.submodule {
              options = {
                terminal = mkOption {type = types.int;};
                desktop = mkOption {type = types.int;};
                popups = mkOption {type = types.int;};
                applications = mkOption {type = types.int;};
              };
            };
          };
        };
      };

      default = {
        monospace = {
          name = "Lilex";
          package = pkgs.lilex;
          features = ["cv09" "cv10" "cv11" "ss01" "ss03"];
        };
        serif = {
          name = "Noto Serif";
          package = pkgs.noto-fonts;
          features = [];
        };
        sansSerif = {
          name = "Open Sans";
          package = pkgs.open-sans;
          features = [];
        };
        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-color-emoji;
          features = [];
        };

        sizes = {
          terminal = 10;
          desktop = 11;
          popups = 11;
          applications = 11;
        };
      };
    };

    extraFontPackages = mkOption {
      description = "Additional font packages to install";
      type = types.listOf types.package;
      default = with pkgs; [ibm-plex];
    };

    fontPackages = mkOption {
      description = "All font packages";
      type = types.listOf types.package;
      readOnly = true;
    };

    palette = mkOption {
      description = "The current palette";
      type = types.attrs;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = lib.mkDefault cfg.flavor;
      accent = lib.mkDefault cfg.accent;
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = with cfg.fonts; {
        monospace = [monospace.name];
        serif = [serif.name];
        sansSerif = [sansSerif.name];
        emoji = [emoji.name];
      };
    };

    theming = {
      fontPackages = with cfg.fonts;
        [
          monospace.package
          serif.package
          sansSerif.package
          emoji.package
        ]
        ++ cfg.extraFontPackages;

      palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").${cfg.flavor}.colors;
    };
  };
}
