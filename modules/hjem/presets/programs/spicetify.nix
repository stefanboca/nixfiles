{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.spicetify;
in {
  options.presets.programs.spicetify = {
    enable = mkEnableOption "spicetify preset";
  };

  config.rum.programs.spicetify = mkIf cfg.enable {
    enable = true;
    wayland = true;
    windowManagerPatch = true;
    enabledExtensions = with pkgs.spicePkgs.extensions; [
      adblockify
      bookmark
    ];
  };
}
