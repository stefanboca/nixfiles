{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (catppuccinLib) applyToModules;
  inherit (catppuccinLib.types) accent flavor;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.trivial) importJSON;
  inherit (lib.types) lazyAttrsOf raw;

  catppuccinLib = import (inputs.catppuccin + "/modules/lib") {inherit config lib pkgs;};

  cfg = config.catppuccin;
in {
  imports = applyToModules (
    [./tty.nix]
    ++ (map (m: inputs.catppuccin + "/modules/nixos/${m}.nix") ["limine" "plymouth" "sddm"])
  );

  options.catppuccin = {
    enable = mkEnableOption "Catppuccin globally";

    flavor = mkOption {
      type = flavor;
      default = "mocha";
      description = "Global Catppuccin flavor";
    };

    accent = mkOption {
      type = accent;
      default = "mauve";
      description = "Global Catppuccin accent";
    };

    sources = mkOption {
      type = lazyAttrsOf raw;
      default = pkgs.catppuccin-sources;
      defaultText = "{ ... }";
      # HACK: without this, overriding one source will delete all others. -@getchoo
      apply = recursiveUpdate pkgs.catppuccin-sources;
      description = "Port sources used across all options";
    };

    palette = mkOption {
      type = lazyAttrsOf raw;
      readOnly = true;
      # taken from `sources.palette` to avoid IFD, and minified with `jq -c .` for size
      default = (importJSON ../../../res/catppuccin/palette.json).${cfg.flavor}.colors;
    };
  };
}
