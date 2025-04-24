{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.theming;

  mkCatppucinColorscheme = style: {
    scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${style}.yaml";
    ghostty = "catppuccin-${style}";
    fish.src = "${inputs.catpucchin-fish}/themes/Catppuccin ${pkgs.lib.strings.toSentenceCase style}.theme";
    neovim.name = "catppuccin";
    neovim.style = style;
    spicetify.theme = inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin or null;
    spicetify.colorScheme = style;
  };

  mkTokyonightColorscheme = style: {
    scheme = "${inputs.tokyonight-nvim}/extras/base24/tokyonight_${style}.yaml";
    ghostty = "tokyonight${if (style == "moon" || style == "night") then "_" else "-"}${style}";
    fish.src = "${pkgs.vimPlugins.tokyonight-nvim}/extras/fish_themes/tokyonight_${style}.theme";
    neovim.name = "tokyonight";
    neovim.style = style;
  };

  colorschemes = {
    catppuccin-frappe = mkCatppucinColorscheme "frappe";
    catppuccin-latte = mkCatppucinColorscheme "latte";
    catppuccin-macchiato = mkCatppucinColorscheme "macchiato";
    catppuccin-mocha = mkCatppucinColorscheme "mocha";

    tokyonight-day = mkTokyonightColorscheme "day";
    tokyonight-moon = mkTokyonightColorscheme "moon";
    tokyonight-night = mkTokyonightColorscheme "night";
    tokyonight-storm = mkTokyonightColorscheme "storm";
  };

  lilexFeatures = [
    "cv09"
    "cv10"
    "cv11"
    "ss01"
    "ss03"
  ];

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

        programs.neovide.settings.font = {
          normal = [ { family = config.stylix.fonts.monospace.name; } ];
          size = config.stylix.fonts.sizes.terminal;
        };
      }

      (lib.mkIf (config.stylix.fonts.monospace.name == "Lilex") {
        programs.neovide.settings.font.features.Lilex = builtins.map (str: "+" + str) lilexFeatures;
        programs.ghostty.settings.font-feature = lilexFeatures;
      })

      (lib.mkIf (colorscheme ? ghostty) {
        programs.ghostty.settings.theme = lib.mkForce colorscheme.ghostty;
      })

      (lib.mkIf (colorscheme ? fish) {
        stylix.targets.fish.enable = false;
        xdg.configFile."fish/themes/${colorscheme.fish.name or cfg.colorscheme}.theme".source = lib.mkIf (
          colorscheme.fish ? src
        ) colorscheme.fish.src;

        home.activation.fishConfigureTheme = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
          run --quiet ${pkgs.fish}/bin/fish -c "
            echo y | fish_config theme save '${colorscheme.fish.name or cfg.colorscheme}'
          "'';
      })

      (lib.mkIf (colorscheme ? neovim) {
        programs.neovim.extraLuaConfig = lib.mkBefore ''
          vim.g.colorscheme = "${colorscheme.neovim.name}"
          ${lib.strings.optionalString (
            colorscheme.neovim ? style
          ) ''vim.g.colorscheme = "${colorscheme.neovim.style}"''}
        '';
      })

      (lib.mkIf (config.programs ? spicetify && colorscheme ? spicetify) (
        lib.mkForce {
          programs.spicetify.theme = colorscheme.spicetify.theme;
          programs.spicetify.colorScheme = colorscheme.spicetify.colorScheme;
        }
      ))

    ]
  );
}
