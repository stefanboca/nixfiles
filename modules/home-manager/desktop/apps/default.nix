{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop;
in {
  imports = [
    ./browser/firefox.nix
    ./spotify.nix
    ./term/ghostty.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
      easyeffects
      gnome-decoder
      helvum
      qpwgraph
      signal-desktop
      telegram-desktop
    ];

    programs.vesktop.enable = true;
    xdg.mimeApps.defaultApplications."x-scheme-handler/discord" = "vesktop.desktop";
  };
}
