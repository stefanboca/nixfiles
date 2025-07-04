{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.theming;
in
{
  options.theming = {
    enable = lib.mkEnableOption "Enable system theming";

    fonts =
      with lib;
      let
        mkFontType =
          typeName:
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
                  default = [ ];
                };
              };
            };
          };

      in
      mkOption {
        description = "Font settings";
        type = types.submodule {
          options = {
            monospace = mkFontType "monospace";
            serif = mkFontType "serif";
            sansSerif = mkFontType "sans-serif";
            emoji = mkFontType "emoji";

            sizes = mkOption {
              description = "Font size settings";
              type = types.submodule {
                options = {
                  terminal = mkOption { type = types.int; };
                  desktop = mkOption { type = types.int; };
                  popups = mkOption { type = types.int; };
                  applications = mkOption { type = types.int; };
                };
              };
            };
          };
        };

        default = {
          monospace = {
            name = "Lilex";
            package = pkgs.lilex;
            features = [
              "cv09"
              "cv10"
              "cv11"
              "ss01"
              "ss03"
            ];
          };
          serif = {
            name = "Noto Serif";
            package = pkgs.noto-fonts;
            features = [ ];
          };
          sansSerif = {
            name = "Open Sans";
            package = pkgs.open-sans;
            features = [ ];
          };
          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-color-emoji;
            features = [ ];
          };

          sizes = {
            terminal = 10;
            desktop = 11;
            popups = 11;
            applications = 11;
          };
        };
      };
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      cache.enable = true;
      flavor = lib.mkDefault "mocha";
      accent = lib.mkDefault "teal";

      sddm = {
        font = cfg.fonts.sansSerif.name;
        fontSize = builtins.toString cfg.fonts.sizes.desktop;
      };
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = with cfg.fonts; {
        monospace = [ monospace.name ];
        serif = [ serif.name ];
        sansSerif = [ sansSerif.name ];
        emoji = [ emoji.name ];
      };
    };
    environment.systemPackages = [
      cfg.fonts.monospace.package
      cfg.fonts.serif.package
      cfg.fonts.sansSerif.package
    ];

  };
}
