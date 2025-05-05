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
  imports = [
    ./browser/firefox.nix
    ./spotify.nix
    ./term/ghostty.nix
  ];

  config = lib.mkIf cfg.enable {
    # TODO: remove nixGL on nixos
    home.packages = (
      builtins.map (pkg: (config.lib.nixGL.wrap pkg)) [
        pkgs.bitwarden
        pkgs.calibre
        pkgs.easyeffects
        pkgs.gnome-decoder
        pkgs.xournalpp
        pkgs.signal-desktop
        pkgs.telegram-desktop
        pkgs.zen-browser # TODO: move to global on nixos
        pkgs.zotero
      ]
    );

    programs.vesktop.enable = true;
  };
}
