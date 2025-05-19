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
    home.packages =
      with pkgs;
      builtins.map (pkg: (config.lib.nixGL.wrap pkg)) [
        bitwarden
        calibre
        easyeffects
        gnome-decoder
        xournalpp
        signal-desktop
        telegram-desktop
        zotero
      ];

    programs.vesktop.enable = true;
  };
}
