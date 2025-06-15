{ inputs, ... }:

{
  flake = {
    overlays = {
      additions = final: prev: {
        inherit (inputs.emmylua-analyzer-rust.packages.${final.system}) emmylua_check emmylua_ls;
        inherit (inputs.firefox-nightly.packages.${final.system}) firefox-nightly-bin;
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${final.system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${final.system};
      };

      inherit (inputs.niri.overlays) niri;
      fenix = inputs.fenix.overlays.default;
      ghostty = inputs.ghostty.overlays.default;
    };
  };
}
