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
      # enable = true; # see note below
      enabledExtensions = with pkgs.spicePkgs.extensions; [
        adblockify
        bookmark
      ];
    };

    # NOTE: manually add package in order to wrap with nixGL
    # TODO: remove on nixos
    home.packages = [
      (config.lib.nixGL.wrap config.programs.spicetify.spicedSpotify)
    ];
  };
}
