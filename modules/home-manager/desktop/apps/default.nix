{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  cfg = config.desktop;
in {
  imports = [
    (modulesPath + "/programs/vesktop.nix")
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
      easyeffects
      gnome-decoder
      helvum
      miro
      qpwgraph
      signal-desktop
      telegram-desktop
    ];

    programs.vesktop = {
      enable = true;
      package = pkgs.vesktop.override {
        withMiddleClickScroll = true;
        withSystemVencord = true;
      };
    };
  };
}
