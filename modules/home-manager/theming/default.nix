{
  config,
  inputs,
  lib,
  modulesPath,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (lib.options) mkOption;
  inherit (lib.types) listOf str;

  cfg = config.theming;
in {
  imports = [
    ../../common/theming
    (lib.modules.importApply (inputs.catppuccin + "/modules/global.nix") {
      catppuccinModules = map (m: inputs.catppuccin + "/modules/home-manager/${m}.nix") [
        # keep-sorted start
        "aerc"
        "atuin"
        "bat"
        "bottom"
        "btop"
        "cursors"
        "eza"
        "firefox"
        "fish"
        "ghostty"
        "gtk"
        "mangohud"
        "obs"
        "vesktop"
        # keep-sorted end
      ];
    })

    # dependencies of catppuccin firefox
    (modulesPath + "/programs/floorp.nix")
    (modulesPath + "/programs/librewolf.nix")
  ];

  options.theming = {
    niri = {
      outputs = mkOption {
        description = "A list of niri outputs to theme";
        type = listOf str;
        default = [];
      };
    };
  };

  config = mkMerge [
    {
      theming = mkIf (osConfig ? theming) {
        enable = mkDefault osConfig.theming.enable;
        flavor = mkDefault osConfig.theming.flavor;
        accent = mkDefault osConfig.theming.accent;
        fonts = mkDefault osConfig.theming.fonts;
      };
    }
    (mkIf cfg.enable {
      catppuccin = {
        cursors.enable = true;
        gtk.icon.enable = true;
      };

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
          outputs = genAttrs cfg.niri.outputs (_: {
            background-color = cfg.palette.mantle.hex;
            backdrop-color = cfg.palette.crust.hex;
          });
          # recent-windows.highlight = {
          #   active.color = cfg.palette.${cfg.accent}.hex;
          #   urgent.color = cfg.palette.red.hex;
          #   corner-radius = 30;
          # };
        };
      };
    })
  ];
}
