{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  toml = pkgs.formats.toml {};

  cfg = config.presets.development.rust;
in {
  options.presets.development.rust = {
    enable = mkEnableOption "rust preset";
  };

  config = mkIf cfg.enable {
    xdg.config.files."kache/config.toml" = {
      generator = toml.generate "kache-config.toml";
      value = {
        cache = {
          local_max_size = "200GiB";
          local_only = true;
        };
      };
    };

    xdg.data.files."cargo/config.toml" = {
      generator = toml.generate "cargo-config.toml";
      value = {
        build.rustc-wrapper = getExe pkgs.kache;
        target.x86_64-unknown-linux-gnu = {
          rustflags = ["-Clink-arg=-fuse-ld=wild"];
        };
      };
    };

    packages = with pkgs; [
      (fenix.complete.withComponents ["cargo" "clippy" "miri" "rust-analysis" "rust-src" "rustc" "rustfmt"])
      bugstalker # cli debugger
      # keep-sorted start
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
      kache # build cache
      wild # linker
      # keep-sorted end
    ];
  };
}
