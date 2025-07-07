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
    documentation.man.generateCaches = true;

    programs = {
      fish.enable = true;
      command-not-found.enable = false;

      nh = {
        enable = true;
        flake = "/home/${config.base.primaryUser}/src/nixfiles";
      };
    };

    environment.systemPackages = with pkgs; [
      age
      bat
      bolt
      cifs-utils
      curl
      dnsutils
      e2fsprogs
      efibootmgr
      evtest
      eza
      fatresize
      fd
      ffmpeg
      file
      fzf
      git
      gnumake
      home-manager
      imagemagick
      jq
      libinput
      lsb-release
      lshw
      nmap
      ouch
      parted
      pciutils
      psmisc
      ripgrep
      sbctl
      sops
      ssh-to-age
      vim
      wev
      wget
    ];
  };
}
