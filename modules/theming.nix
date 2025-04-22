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
      scheme = {
        slug = "tokyonight-day";
        scheme = "Tokyonight Day";
        base00 = "#e1e2e7";
        base01 = "#a8aecb";
        base02 = "#848cb5";
        base03 = "#848cb5";
        base04 = "#7847bd";
        base05 = "#3760bf";
        base06 = "#2e5857";
        base07 = "#3760bf";
        base08 = "#f52a65";
        base09 = "#b15c00";
        base0A = "#8c6c3e";
        base0B = "#587539";
        base0C = "#007197";
        base0D = "#2e7de9";
        base0E = "#9854f1";
        base0F = "#07879d";
      };
      ghosttyTheme = "tokyonight_day";
      fishTheme.src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/fish_themes/tokyonight_day.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "day";
      };
    };
    tokyonight-moon = {
      scheme = {
        slug = "tokyonight-moon";
        scheme = "Tokyonight Moon";
        base00 = "#222436";
        base01 = "#3b4261";
        base02 = "#636da6";
        base03 = "#636da6";
        base04 = "#fca7ea";
        base05 = "#c8d3f5";
        base06 = "#b4f9f8";
        base07 = "#c8d3f5";
        base08 = "#ff757f";
        base09 = "#ff966c";
        base0A = "#ffc777";
        base0B = "#c3e88d";
        base0C = "#86e1fc";
        base0D = "#82aaff";
        base0E = "#c099ff";
        base0F = "#0db9d7";
      };
      ghosttyTheme = "tokyonight_moon";
      fishTheme.src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/fish_themes/tokyonight_moon.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "moon";
      };
    };
    tokyonight-night = {
      scheme = {
        slug = "tokyonight-night";
        scheme = "Tokyonight Night";
        base00 = "#1a1b26";
        base01 = "#3b4261";
        base02 = "#565f89";
        base03 = "#565f89";
        base04 = "#9d7cd8";
        base05 = "#c0caf5";
        base06 = "#b4f9f8";
        base07 = "#c0caf5";
        base08 = "#f7768e";
        base09 = "#ff9e64";
        base0A = "#e0af68";
        base0B = "#9ece6a";
        base0C = "#7dcfff";
        base0D = "#7aa2f7";
        base0E = "#bb9af7";
        base0F = "#0db9d7";
      };
      ghosttyTheme = "tokyonight_night";
      fishTheme.src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/fish_themes/tokyonight_night.theme";
      neovimTheme = {
        name = "tokyonight";
        style = "night";
      };
    };
    tokyonight-storm = {
      scheme = {
        slug = "tokyonight-storm";
        scheme = "Tokyonight Storm";
        base00 = "#24283b";
        base01 = "#3b4261";
        base02 = "#565f89";
        base03 = "#565f89";
        base04 = "#9d7cd8";
        base05 = "#c0caf5";
        base06 = "#b4f9f8";
        base07 = "#c0caf5";
        base08 = "#f7768e";
        base09 = "#ff9e64";
        base0A = "#e0af68";
        base0B = "#9ece6a";
        base0C = "#7dcfff";
        base0D = "#7aa2f7";
        base0E = "#bb9af7";
        base0F = "#0db9d7";
      };
      ghosttyTheme = "tokyonight_storm";
      fishTheme.src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/fish_themes/tokyonight_storm.theme";
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
          # TODO: find a good serif font
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

        programs.fish.interactiveShellInit = ''
          if not set -q fish_theme
            echo y | fish_config theme save "${colorscheme.fishTheme.name or cfg.colorscheme}"
            set -U fish_theme 1
          end
        '';
        home.activation.resetFishTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run --quiet ${pkgs.fish}/bin/fish -c "set -e fish_theme"
        '';
      })
    ]
  );
}
