{inputs, ...}: {
  flake = {
    overlays = {
      additions = final: _prev: let
        inherit (final.stdenv.hostPlatform) system;
      in {
        inherit (inputs.firefox-nightly.packages.${system}) firefox-nightly-bin;
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
      };

      overrides = _final: prev: {
        # remove gnome from dependencies
        xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (prevAttrs: {
          buildInputs = builtins.filter (x: x != prev.gnome-desktop) prevAttrs.buildInputs;
          mesonFlags = ["-Dwallpaper=disabled"];
        });

        # use latest version of nix, to avoid having multiple versions in store
        nixos-option = prev.nixos-option.override {nix = prev.nixVersions.latest;};
        comma = prev.comma.override {nix = prev.nixVersions.latest;};
      };

      inherit (inputs.niri.overlays) niri;
      fenix = inputs.fenix.overlays.default;
    };
  };
}
