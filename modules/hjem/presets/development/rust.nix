{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.development.rust;
in {
  options.presets.development.rust = {
    enable = mkEnableOption "rust preset";
  };

  config = mkIf cfg.enable {
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
      wild # linker
      # keep-sorted end
    ];
  };
}
