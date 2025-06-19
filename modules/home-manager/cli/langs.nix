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
      # gh
      zizmor # github actions static analysis tool

      # lua
      emmylua_check

      # typst
      typst

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
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      rust-analyzer-nightly

      # zig
      zig
    ];

    programs = {
      # python
      uv.enable = true;

      #go
      go = {
        enable = true;
        goPath = "${config.xdg.dataHome}/go";
      };
    };

    xdg.dataFile."cargo/config.toml".source = (pkgs.formats.toml { }).generate "cargo-config" {
      net.git-fetch-with-cli = true;
      unstable.gc = true;
    };
  };
}
