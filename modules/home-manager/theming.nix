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
  imports = [ ../common/theming.nix ];

  config = lib.mkIf cfg.enable {
    catppuccin = {
      gtk.enable = true;
      nvim.enable = false;
    };

    home.packages = with cfg.fonts; [
      monospace.package
      serif.package
      sansSerif.package
      emoji.package
    ];

    gtk.enable = true;
    programs = {
      ghostty.settings = {
        font-family = cfg.fonts.monospace.name;
        font-size = cfg.fonts.sizes.terminal;
        font-feature = cfg.fonts.monospace.features;
      };
      spicetify = {
        theme = pkgs.spicePkgs.themes.catppuccin;
        colorScheme = config.catppuccin.flavor;
      };
      neovide.settings.font = {
        normal = [ { family = cfg.fonts.monospace.name; } ];
        size = cfg.fonts.sizes.terminal;
        features.${cfg.fonts.monospace.name} = builtins.map (str: "+" + str) cfg.fonts.monospace.features;
      };

      neovim.extraLuaConfig =
        lib.mkBefore # lua
          ''
            vim.g.catppuccin_flavor = ${config.catppuccin.flavor}
          '';
    };
  };
}
