inputs: {
  default = _final: prev: import ./pkgs prev;

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

  dank-material-shell = final: prev: let
    inherit (final.stdenv.hostPlatform) system;
  in {
    dmsPkgs =
      {
        inherit (inputs.dank-material-shell.packages.${system}) dms-shell;
        inherit (inputs.dank-material-shell.inputs.dgop.packages.${system}) dgop;
      }
      // inputs.dank-material-shell.inputs.quickshell.overlays.default final prev;
  };

  inherit (inputs.niri.overlays) niri;
  fenix = inputs.fenix.overlays.default;
  firefox-nightly = inputs.firefox-nightly.overlays.default;
  snv = inputs.snv.overlays.default;
  spicetify = final: _prev: {spicePkgs = inputs.spicetify-nix.legacyPackages.${final.stdenv.hostPlatform.system};};
}
