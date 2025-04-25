{ config, pkgs, ... }:

{
  imports = [ ./spotify.nix ];

  home.packages = (
    builtins.map (pkg: (config.lib.nixGL.wrap pkg)) [
      pkgs.bitwarden
      pkgs.blender
      pkgs.calibre
      pkgs.discord
      pkgs.easyeffects
      pkgs.geogebra6
      pkgs.gnome-decoder
      pkgs.jetbrains.idea-community
      pkgs.musescore
      pkgs.prusa-slicer
      pkgs.rnote
      pkgs.signal-desktop
      pkgs.telegram-desktop
      pkgs.xournalpp
      pkgs.zotero
    ]
  );

  programs.obs-studio = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.obs-studio);
  };
}
