{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) lazyAttrsOf raw;

  catppuccinLib = import (inputs.catppuccin + "/modules/lib") {inherit config lib pkgs;};

  upstreamSources = (import inputs.catppuccin {inherit pkgs;}).packages;
  defaultSources =
    upstreamSources
    // {
      firefox = upstreamSources.firefox.overrideAttrs {
        patches = [./pkgs/firefox/write-themes-to-json.patch];
        installPhase = ''
          mkdir -p $out
          mv themes/* $out
        '';
      };
    };
in {
  imports = catppuccinLib.applyToModules (listFilesRecursive ./programs);

  options.catppuccin = {
    enable = mkEnableOption "Catppuccin globally";

    flavor = mkOption {
      type = catppuccinLib.types.flavor;
      default = "mocha";
      description = "Global Catppuccin flavor";
    };

    accent = mkOption {
      type = catppuccinLib.types.accent;
      default = "mauve";
      description = "Global Catppuccin accent";
    };

    sources = mkOption {
      type = lazyAttrsOf raw;
      default = defaultSources;
      defaultText = "{ ... }";
      # HACK!
      # without this, overriding one source will delete all others. -@getchoo
      apply = recursiveUpdate defaultSources;
      description = "Port sources used across all options";
    };
  };
}
