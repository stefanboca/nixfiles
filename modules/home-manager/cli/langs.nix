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
    home.packages = [
      # gh
      pkgs.zizmor # github actions static analysis tool

      # typst
      pkgs.typst

      # rust
      pkgs.cargo-cache # rust cache cli
      pkgs.cargo-machete # find unused crates
      pkgs.cargo-nextest # better cargo test
      pkgs.cargo-udeps # find unused crates
      pkgs.cargo-watch # run cargo commands on project changes
      pkgs.cargo-wizard # configure cargo projects for best performance
      pkgs.ra-multiplex # run a single rust-analyzer instance
      (pkgs.fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      pkgs.rust-analyzer-nightly

      # zig
      pkgs.zig
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

    xdg.configFile = {
      "cargo/config.toml".text = ''
        [net]
        git-fetch-with-cli = true
      '';
    };
  };
}
