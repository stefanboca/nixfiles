{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.users.stefan;
in {
  options.presets.users.stefan = {
    enable = mkEnableOption "stefan";
  };

  config = mkIf cfg.enable {
    packages = with pkgs; [
      cmakeCurses
      elan # lean4
      emmylua-check
      gcc
      koto
      typst
      typstyle
      uv
      zig
      zizmor # github actions static analysis tool
    ];

    catppuccin = {
      misc.cursors = {
        enable = true;
        integrations = {
          gtk.enable = true;
          niri.enable = true;
        };
      };
      programs = {
        eza.enable = true;
        spicetify.enable = true;
      };
    };

    presets = {
      desktops.niri.enable = true;
      development.rust.enable = true;
      misc.xdg.enable = true;
      misc.gtk.enable = true;
      programs = {
        # keep-sorted start block=true
        cli.enable = true;
        firefox.enable = true;
        fish.enable = true;
        ghostty.enable = true;
        neovim = {
          enable = true;
          neovide.enable = true;
        };
        spicetify.enable = true;
        ssh.enable = true;
        vcs.enable = true;
        vesktop.enable = true;
        # keep-sorted end
      };
    };
  };
}
