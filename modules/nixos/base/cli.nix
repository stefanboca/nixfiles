{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.base;
in {
  config = lib.mkIf cfg.enable {
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
      inotify-tools
      jq
      libinput
      lsb-release
      lshw
      net-tools
      nix-output-monitor
      nmap
      ouch
      parted
      pciutils
      powertop
      psmisc
      ripgrep
      sbctl
      sops
      ssh-to-age
      steam-run
      usbutils
      vim
      wev
      wget
    ];
  };
}
