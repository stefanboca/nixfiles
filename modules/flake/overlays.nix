{ inputs, ... }:

{
  flake = {
    overlays = {
      # adds some flake inputs to packages
      additions = final: prev: {
        inherit (inputs.emmylua-analyzer-rust.packages.${final.system}) emmylua_check emmylua_ls;
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${final.system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${final.system};

        firefox-nightly = inputs.firefox-nightly.packages.${final.system}.firefox-nightly-bin;
        zen-browser = inputs.zen-browser.packages.${final.system}.default;
        zen-browser-unwrapped = inputs.zen-browser.packages.${final.system}.zen-browser-unwrapped;
      };

      ghostty = inputs.ghostty.overlays.default;
      fenix = inputs.fenix.overlays.default;
    };
  };
}
