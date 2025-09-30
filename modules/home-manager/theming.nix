{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.theming;
in {
  imports = [../common/theming.nix];

  options.theming = with lib; {
    niri = {
      outputs = mkOption {
        description = "A list of niri outputs to theme";
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      cursors.enable = true;
      nvim.enable = false;
      gtk.icon.enable = false;
    };

    home.packages = cfg.fontPackages;

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      dotIcons.enable = false;
    };
    xresources.path = "${config.xdg.configHome}/X11/xresources";

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

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
        normal = [{family = cfg.fonts.monospace.name;}];
        size = cfg.fonts.sizes.terminal;
        features.${cfg.fonts.monospace.name} = builtins.map (str: "+" + str) cfg.fonts.monospace.features;
      };

      neovim.extraLuaConfig =
        lib.mkBefore # lua
        
        ''
          vim.g.catppuccin_flavor = ${config.catppuccin.flavor}
        '';

      niri.settings = {
        cursor = {
          theme = config.home.pointerCursor.name;
          inherit (config.home.pointerCursor) size;
        };
        layout = {
          background-color = cfg.palette.mantle.hex;
          focus-ring = {
            inactive.color = cfg.palette.overlay1.hex;
            active.color = cfg.palette.${cfg.accent}.hex;
            urgent.color = cfg.palette.red.hex;
          };
          shadow = {
            color = cfg.palette.crust.hex;
            inactive-color = cfg.palette.crust.hex;
          };
        };
        outputs = lib.genAttrs cfg.niri.outputs (_: {
          background-color = cfg.palette.mantle.hex;
          backdrop-color = cfg.palette.crust.hex;
        });
      };
    };
  };
}
