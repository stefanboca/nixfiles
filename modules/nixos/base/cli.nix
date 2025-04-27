{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.base;
in
{
  config = lib.mkIf cfg.enable {
    documentation.man.generateCaches = false;

    programs = {
      fish.enable = true;

      nh = {
        enable = true;
        flake = "/home/${config.base.primaryUser}/data/nixfiles";
      };
    };

    environment.systemPackages = [
      pkgs.bat
      pkgs.curl
      pkgs.eza
      pkgs.fd
      pkgs.ffmpeg
      pkgs.file
      pkgs.fzf
      pkgs.git
      pkgs.home-manager
      pkgs.jq
      pkgs.killall
      pkgs.lsb-release
      pkgs.ripgrep
      pkgs.wget
    ];
  };
}
