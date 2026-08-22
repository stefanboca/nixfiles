{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkForce mkIf;
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

    environment = {
      sessionVariables.NIX_LD_LIBRARY_PATH = mkForce "/run/opengl-driver/lib:/run/current-system/sw/share/nix-ld/lib";
      systemPackages = with pkgs; [
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
    };

    boot.plymouth.enable = true;

    programs = {
      nh.enable = true;
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          # keep-sorted start
          dbus
          fontconfig
          freetype
          glib
          libGL
          libglvnd
          libice
          libsm
          libx11
          libxcb
          libxcb-cursor
          libxcb-image
          libxcb-keysyms
          libxcb-render-util
          libxcb-util
          libxcb-wm
          libxext
          libxkbcommon
          stdenv.cc.cc
          wayland
          zlib
          # keep-sorted end
        ];
      };
    };

    documentation = {
      dev.enable = true;
      man.cache.enable = true;
    };
  };
}
