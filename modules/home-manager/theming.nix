{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

# TODO: integrate with nixos

let
  cfg = config.theming;

  mkCatppucinColorscheme = style: {
    scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${style}.yaml";
    ghostty = "catppuccin-${style}";
    fish.src = "${inputs.catppuccin-fish}/themes/Catppuccin ${pkgs.lib.strings.toSentenceCase style}.theme";
    neovim.name = "catppuccin";
    neovim.style = style;
    spicetify.theme = pkgs.spicePkgs.themes.catppuccin;
    spicetify.colorScheme = style;
  };

  mkTokyonightColorscheme = style: {
    scheme = "${inputs.tokyonight-nvim}/extras/base24/tokyonight_${style}.yaml";
    ghostty = "tokyonight${if (style == "moon" || style == "night") then "_" else "-"}${style}";
    fish.src = "${inputs.tokyonight-nvim}/extras/fish_themes/tokyonight_${style}.theme";
    neovim.name = "tokyonight";
    neovim.style = style;
  };

  lilexFeatures = [
    "cv09"
    "cv10"
    "cv11"
    "ss01"
    "ss03"
  ];

  colorscheme = cfg.colorschemes.${cfg.colorscheme};
in
{
  options.theming = with lib.types; {
    enable = lib.mkEnableOption "";

    colorscheme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames cfg.colorschemes);
    };

    colorschemes = lib.mkOption {
      type = attrsOf (submodule {
        options = {
          scheme = lib.mkOption {
            type = oneOf [
              path
              lines
              attrs
            ];
          };

          ghostty = lib.mkOption {
            type = nullOr (oneOf [
              path
              str
            ]);
            default = null;
          };

          fish = lib.mkOption {
            type = nullOr (submodule {
              options = {
                name = lib.mkOption {
                  type = nullOr str;
                  default = null;
                };
                src = lib.mkOption {
                  type = path;
                  default = null;
                };
              };
            });
            default = null;
          };

          neovim = lib.mkOption {
            type = nullOr (submodule {
              options = {
                name = lib.mkOption {
                  type = str;
                };
                style = lib.mkOption {
                  type = nullOr str;
                  default = null;
                };
              };
            });
            default = null;
          };

          spicetify = lib.mkOption {
            type = nullOr (submodule {
              options = {
                theme = lib.mkOption {
                  type = package;
                };
                colorScheme = lib.mkOption {
                  type = str;
                };
              };
            });
            default = null;
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        theming.colorschemes = {
          catppuccin-frappe = mkCatppucinColorscheme "frappe";
          catppuccin-latte = mkCatppucinColorscheme "latte";
          catppuccin-macchiato = mkCatppucinColorscheme "macchiato";
          catppuccin-mocha = mkCatppucinColorscheme "mocha";

          tokyonight-day = mkTokyonightColorscheme "day";
          tokyonight-moon = mkTokyonightColorscheme "moon";
          tokyonight-night = mkTokyonightColorscheme "night";
          tokyonight-storm = mkTokyonightColorscheme "storm";
        };

        stylix = {
          enable = true;
          overlays.enable = false;
          base16Scheme = colorscheme.scheme;
          fonts = {
            monospace = {
              package = pkgs.lilex;
              name = "Lilex";
            };
            serif = {
              package = pkgs.noto-fonts;
              name = "Noto Serif";
            };
            sansSerif = {
              package = pkgs.open-sans;
              name = "Open Sans";
            };

            sizes = {
              terminal = 10;
              desktop = 11;
              popups = 11;
              applications = 11;
            };
          };
          targets = {
            blender.enable = false;
            gtk.flatpakSupport.enable = false;
            neovim.enable = false;
            sxiv.enable = false;
            xresources.enable = false;
          };
        };

        programs.neovide.settings.font = {
          normal = [ { family = config.stylix.fonts.monospace.name; } ];
          size = config.stylix.fonts.sizes.terminal;
        };
      }

      (lib.mkIf (config.stylix.fonts.monospace.name == "Lilex") {
        programs.neovide.settings.font.features.Lilex = builtins.map (str: "+" + str) lilexFeatures;
        programs.ghostty.settings.font-feature = lilexFeatures;
      })

      (lib.mkIf (colorscheme.ghostty != null) {
        programs.ghostty.settings.theme = lib.mkForce colorscheme.ghostty;
      })

      (lib.mkIf (colorscheme.fish != null) {
        stylix.targets.fish.enable = false;
        xdg.configFile."fish/themes/${lib.defaultTo cfg.colorscheme colorscheme.fish.name}.theme".source =
          colorscheme.fish.src;

        home.activation.configureFishTheme = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
          run --quiet ${pkgs.fish}/bin/fish -c "
            echo y | fish_config theme save '${lib.defaultTo cfg.colorscheme colorscheme.fish.name}'
          "'';
      })

      (lib.mkIf (colorscheme.neovim != null) {
        programs.neovim.extraLuaConfig = lib.mkBefore ''
          vim.g.colorscheme = "${colorscheme.neovim.name}"
          ${lib.strings.optionalString (
            colorscheme.neovim.style != null
          ) ''vim.g.colorscheme_style = "${colorscheme.neovim.style}"''}
        '';
      })

      (lib.mkIf (config.programs ? spicetify && colorscheme.spicetify != null) (
        lib.mkForce {
          programs.spicetify.theme = colorscheme.spicetify.theme;
          programs.spicetify.colorScheme = colorscheme.spicetify.colorScheme;
        }
      ))

    ]
  );
}
