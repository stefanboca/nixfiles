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
      # TODO: test remove steam-run-libs.
      nix-ld = {
        enable = true;
        libraries = [
          (pkgs.runCommand "steam-run-libs" {} ''mkdir $out; ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib'')
        ];
      };
    };

    documentation = {
      dev.enable = true;
      man.generateCaches = true;
    };
  };
}
