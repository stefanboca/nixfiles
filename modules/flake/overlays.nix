{ inputs, ... }:

{
  flake = {
    overlays = {
      # adds my custom packages
      additions = final: prev: {
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${final.system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${final.system};
      };

      ghostty = inputs.ghostty.overlays.default;
      fenix = inputs.fenix.overlays.default;
    };
  };
}
