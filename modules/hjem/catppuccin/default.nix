{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) importJSON;
  inherit (lib.modules) importApply mkIf mkDefault;
  inherit (lib.types) freeformType str;

  hasOsConfig = osConfig ? catppuccin;
  osCfg = osConfig.catppuccin;
in {
  imports = [
    (importApply (inputs.catppuccin + "/modules/global.nix") {
      catppuccinModules =
        (listFilesRecursive ./desktops) ++ (listFilesRecursive ./programs) ++ (listFilesRecursive ./misc);
    })
  ];

  options = {
    catppuccin.palette = mkOption {
      description = "Global Catppuccin palette";
      inherit (pkgs.formats.json {}) type;
      readOnly = true;
    };

    # hack to make the global module work
    nix.settings = mkOption {type = freeformType;};
    system.nixos.release = mkOption {
      type = str;
      readOnly = true;
      default = osConfig.system.nixos.release;
    };
  };

  config.catppuccin = {
    enable = mkIf hasOsConfig (mkDefault osCfg.enable);
    autoEnable = mkIf hasOsConfig (mkDefault osCfg.autoEnable);
    flavor = mkIf hasOsConfig (mkDefault osCfg.flavor);
    accent = mkIf hasOsConfig (mkDefault osCfg.accent);
    sources = mkIf hasOsConfig (mkDefault osCfg.sources);
    palette = importJSON ../../../res/catppuccin/palette.json;
  };
}
