{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (catppuccinLib) applyToModules;
  inherit (catppuccinLib.types) accent flavor;
  inherit (lib.attrsets) optionalAttrs recursiveUpdate;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.trivial) importJSON;
  inherit (lib.types) lazyAttrsOf raw;

  catppuccinLib = import (inputs.catppuccin + "/modules/lib") {inherit config lib pkgs;};

  hasOsConfig = osConfig ? catppuccin;

  cfg = config.catppuccin;
  osCfg = osConfig.catppuccin;
in {
  # TODO:
  # - mako
  # - btop
  # - starship? (currently requires IFD)
  imports = applyToModules ((listFilesRecursive ./desktops) ++ (listFilesRecursive ./programs) ++ (listFilesRecursive ./misc));

  options.catppuccin = {
    enable = (mkEnableOption "Catppuccin globally") // optionalAttrs hasOsConfig {default = osCfg.enable;};

    flavor = mkOption ({
        type = flavor;
        default = "mocha";
        description = "Global Catppuccin flavor";
      }
      // optionalAttrs hasOsConfig {default = osCfg.flavor;});

    accent = mkOption ({
        type = accent;
        default = "mauve";
        description = "Global Catppuccin accent";
      }
      // optionalAttrs hasOsConfig {default = osCfg.accent;});

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
