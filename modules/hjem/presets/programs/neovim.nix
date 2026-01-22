{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.neovim;
in {
  options.presets.programs.neovim = {
    enable = mkEnableOption "neovim preset";
    neovide.enable = mkEnableOption "neovide preset";
  };

  config = mkIf cfg.enable {
    packages = [pkgs.snv];
    environment.sessionVariables = {
      EDITOR = "snv";
      VISUAL = "snv";
    };

    rum.programs.neovide = mkIf cfg.neovide.enable {
      enable = true;
      settings = {
        neovim-bin = getExe pkgs.snv;
        fork = true;
        frame = "none";
        title-hidden = true;

        font = {
          normal = [{family = "Lilex";} {family = "Symbols Nerd Font Mono";}];
          size = 10;
          features.Lilex = ["+cv09" "+cv10" "+cv11" "+ss01" "+ss03"];
        };
      };
    };
  };
}
