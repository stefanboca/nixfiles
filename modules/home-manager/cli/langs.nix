{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.cli;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      koto
      lean4
      zig

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
      cargo-insta # snapshot testing tool
      cargo-nextest # better cargo test
      cargo-shear # find unused dependencies
      cargo-watch # run cargo commands on project changes
      cargo-wizard # configure cargo projects for best performance
      ra-multiplex # run a single rust-analyzer instance
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "miri"
        "rust-analysis"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      rust-analyzer-nightly
    ];

    programs = {
      # python
      uv.enable = true;

      #go
      go = {
        enable = true;
        env.GOPATH = "${config.xdg.dataHome}/go";
      };
    };

    xdg.dataFile."cargo/config.toml".source = (pkgs.formats.toml { }).generate "cargo-config" {
      net.git-fetch-with-cli = true;
      unstable.gc = true;
    };
  };
}
