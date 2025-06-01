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
      command-not-found.enable = false;

      nh = {
        enable = true;
        flake = "/home/${config.base.primaryUser}/data/nixfiles";
      };
    };

    environment.systemPackages = with pkgs; [
      age
      bat
      curl
      e2fsprogs
      efibootmgr
      eza
      fatresize
      fd
      ffmpeg
      file
      fzf
      gcc
      git
      gnumake
      home-manager
      imagemagick
      jq
      killall
      lsb-release
      lshw
      nix-index
      nmap
      parted
      ripgrep
      sops
      ssh-to-age
      vim
      wget
    ];
  };
}
