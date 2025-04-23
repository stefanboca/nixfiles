{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.theming;

  colorschemes = {
    catppuccin-frappe = {
      scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      ghosttyTheme = "catppuccin-frappe";
      fishTheme.src = "${inputs.catpucchin-fish}/themes/Catppuccin Frappe.theme";
      neovimTheme = {
        name = "catppuccin";
        style = "frappe";
      };
    };
    catppuccin-latte = {
      scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
      ghosttyTheme = "catppuccin-latte";
      fishTheme.src = "${inputs.catpucchin-fish}/themes/Catppuccin Latte.theme";
      neovimTheme = {
        name = "catppuccin";
        style = "latte";
      };
    };
    catppuccin-macchiato = {
      scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      ghosttyTheme = "catppuccin-macchiato";
      fishTheme.src = "${inputs.catpucchin-fish}/themes/Catppuccin Macchiato.theme";
      neovimTheme = {
        name = "catppuccin";
        style = "macchiato";
      };
    };
    catppuccin-mocha = {
      scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      ghosttyTheme = "catppuccin-mocha";
      fishTheme.src = "${inputs.catppuccin-fish}/themes/Catppuccin Mocha.theme";
      neovimTheme = {
        name = "catppuccin";
        style = "mocha";
      };
    };

    tokyonight-day = {
      scheme = "${inputs.tokyonight-nvim}/extras/base24/tokyonight_day.yaml";
      ghosttyTheme = "tokyonight_day";
      fishTheme.src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/fish_themes/tokyonight_day.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "day";
      };
    };
    tokyonight-moon = {
      scheme = "${inputs.tokyonight-nvim}/extras/base24/tokyonight_moon.yaml";
      ghosttyTheme = "tokyonight_moon";
      fishTheme.src = "${inputs.tokyonight-nvim}/extras/fish_themes/tokyonight_moon.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "moon";
      };
    };
    tokyonight-night = {
      scheme = "${inputs.tokyonight-nvim}/extras/base24/tokyonight_night.yaml";
      ghosttyTheme = "tokyonight_night";
      fishTheme.src = "${inputs.tokyonight-nvim}/extras/fish_themes/tokyonight_night.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "night";
      };
    };
    tokyonight-storm = {
      scheme = "${inputs.tokyonight-nvim}/extras/base24/tokyonight_storm.yaml";
      ghosttyTheme = "tokyonight_storm";
      fishTheme.src = "${inputs.tokyonight-nvim}/extras/fish_themes/tokyonight_storm.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "storm";
      };
    };
  };

  colorscheme = colorschemes.${cfg.colorscheme};
in
{
  options.theming = {
    enable = lib.mkEnableOption "";

    colorscheme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames colorschemes);
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        stylix.enable = true;
        stylix.targets.neovim.enable = false;
        stylix.targets.gtk.flatpakSupport.enable = false;

        stylix.base16Scheme = colorscheme.scheme;

        stylix.fonts = {
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

        programs.neovim.extraLuaConfig = lib.mkIf (colorscheme ? neovimTheme) (
          lib.mkBefore ''
            vim.g.colorscheme = "${colorscheme.neovimTheme.name}"
            ${
              if (colorscheme.neovimTheme ? style) then
                ''vim.g.colorscheme_style = "${colorscheme.neovimTheme.style}"''
              else
                ""
            }
          ''
        );

        programs.neovide.settings.font = {
          normal = [ { family = config.stylix.fonts.monospace.name; } ];
          size = config.stylix.fonts.sizes.terminal;
          features = lib.mkIf (config.stylix.fonts.monospace.name == "Lilex") {
            Lilex = [
              "+cv09"
              "+cv10"
              "+cv11"
              "+ss01"
              "+ss03"
            ];
          };
        };

        programs.ghostty.settings.theme = lib.mkIf (colorscheme ? ghosttyTheme) (
          lib.mkForce colorscheme.ghosttyTheme
        );
        programs.ghostty.settings.font-feature = lib.mkIf (config.stylix.fonts.monospace.name == "Lilex") [
          "cv09"
          "cv10"
          "cv11"
          "ss01"
          "ss03"
        ];
      }

      (lib.mkIf (colorscheme ? fishTheme) {
        stylix.targets.fish.enable = false;
        xdg.configFile."fish/themes/${colorscheme.fishTheme.name or cfg.colorscheme}.theme".source =
          lib.mkIf (colorscheme.fishTheme ? src)
            colorscheme.fishTheme.src;

        home.activation.fishConfigureTheme = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
          run --quiet ${pkgs.fish}/bin/fish -c "
            echo y | fish_config theme save '${colorscheme.fishTheme.name or cfg.colorscheme}'
          "'';
      })
    ]
  );
}
