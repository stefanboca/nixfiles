{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.common;
in {
  options.presets.common = {
    enable = mkEnableOption "common preset";
  };

  config = mkIf cfg.enable {
    presets = {
      fonts.enable = true;
      minimal.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      evtest
      fatresize
      ffmpeg
      fzf
      git
      gnumake
      imagemagick
      jq
      libinput
      man-pages
      man-pages-posix
      wev
      # keep-sorted end
    ];

    boot.plymouth.enable = true;

    programs = {
      nh.enable = true;
      nix-ld.enable = true;
    };

    documentation = {
      dev.enable = true;
      man.generateCaches = true;
    };
  };
}
