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

    environment.systemPackages = with pkgs; [
      bat
      curl
      eza
      fd
      ffmpeg
      file
      fzf
      git
      home-manager
      jq
      killall
      lsb-release
      lshw
      ripgrep
      vim
      wget
    ];
  };
}
