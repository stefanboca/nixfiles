{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  cfg = config.cli;
in {
  imports = [
    (modulesPath + "/programs/go.nix")
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      koto
      lean4
      zig

      # python
      uv

      # c / cpp
      cmakeCurses
      gcc

      # github actions
      zizmor # github actions static analysis tool

      # lua
      emmylua-check

      # typst
      typst
      typstyle

      # rust
      bugstalker # cli debugger
      cargo-auditable # make production Rust binaries auditable
      cargo-cache # rust cache cli
      cargo-sweep # clean up unused build files
      cargo-clean-recursive # cleans all projects under specified directory
      cargo-insta # snapshot testing tool
      cargo-nextest # better cargo test
      cargo-shear # find unused dependencies
      cargo-watch # run cargo commands on project changes
      cargo-wizard # configure cargo projects for best performance
      (fenix.complete.withComponents ["cargo" "clippy" "miri" "rust-analysis" "rust-src" "rustc" "rustfmt"])
    ];

    programs = {
      #go
      go = {
        enable = true;
        telemetry.mode = "off";
        env.GOPATH = "${config.xdg.dataHome}/go";
      };
    };

    xdg.dataFile."cargo/config.toml".source = (pkgs.formats.toml {}).generate "cargo-config" {
      net.git-fetch-with-cli = true;
      unstable.gc = true;
    };
  };
}
