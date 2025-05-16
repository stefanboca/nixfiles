{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true; # see note below
      enabledExtensions = with pkgs.spicePkgs.extensions; [
        adblockify
        bookmark
      ];
    };
  };
}
