{ inputs, ... }:

{
  flake = {
    overlays = {
      # adds some flake inputs to packages
      additions = final: prev: {
        inherit (inputs.emmylua-analyzer-rust.packages.${final.system}) emmylua_check emmylua_ls;
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${final.system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${final.system};
      };

      ghostty = inputs.ghostty.overlays.default;
      fenix = inputs.fenix.overlays.default;
    };
  };
}
