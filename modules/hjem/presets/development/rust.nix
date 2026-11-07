{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  toml = pkgs.formats.toml {};

  cfg = config.presets.development.rust;
in {
  options.presets.development.rust = {
    enable = mkEnableOption "rust preset";
  };

  config = mkIf cfg.enable {
    xdg.data.files."cargo/config.toml" = {
      generator = toml.generate "cargo-config.toml";
      value = {
        target = {
          x86_64-unknown-linux-gnu.rustflags = ["-Clink-arg=-fuse-ld=wild"];
          # wasm32-unknown-unknown = {
          #   linker = getExe pkgs.wild-unwrapped;
          #   rustflags = ["-Clinker-flavor=wasm-ld"];
          # };
        };
      };
    };

    packages = with pkgs; [
      (fenix.complete.withComponents [
        # keep-sorted start
        "cargo"
        "clippy"
        "miri"
        "rust-analysis"
        "rust-src"
        "rustc"
        "rustc-codegen-cranelift-preview"
        "rustfmt"
        # keep-sorted end
      ])
      # keep-sorted start
      bugstalker # cli debugger
      cargo-auditable # make production Rust binaries auditable
      cargo-cache # rust cache cli
      cargo-clean-recursive # cleans all projects under specified directory
      cargo-insta # snapshot testing tool
      cargo-nextest # better cargo test
      cargo-shear # find unused dependencies
      cargo-sweep # clean up unused build files
      cargo-watch # run cargo commands on project changes
      cargo-wizard # configure cargo projects for best performance
      clang # for cc
      wild # linker
      # keep-sorted end
    ];
  };
}
