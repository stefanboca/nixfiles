{inputs, ...}: {
  flake = {
    overlays = {
      additions = final: _prev: {
        inherit (inputs.firefox-nightly.packages.${final.system}) firefox-nightly-bin;
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${final.system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${final.system};
      };

      overrides = _final: prev: {
        # remove gnome from dependencies
        xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (prevAttrs: {
          buildInputs = builtins.filter (x: x != prev.gnome-desktop && x != prev.gnome-settings-daemon) prevAttrs.buildInputs;
          mesonFlags = ["-Dwallpaper=disabled"];
        });

        # use latest version of nix, to avoid having multiple versions in store
        nixos-option = prev.nixos-option.override {nix = prev.nixVersions.latest;};
        comma = prev.comma.override {nix = prev.nixVersions.latest;};

        # use nightly quickshell and add qtmultimedia
        quickshell = inputs.dank-material-shell.packages.${prev.system}.quickshell.overrideAttrs (prevAttrs: {
          buildInputs = prevAttrs.buildInputs ++ [prev.qt6.qtmultimedia];
        });
      };

      inherit (inputs.niri.overlays) niri;
      fenix = inputs.fenix.overlays.default;
    };
  };
}
