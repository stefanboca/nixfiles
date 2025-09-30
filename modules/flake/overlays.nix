{ inputs, ... }:

{
  flake = {
    overlays = {
      additions = final: prev: {
        inherit (inputs.firefox-nightly.packages.${final.system}) firefox-nightly-bin;
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${final.system}.default;
        spicePkgs = inputs.spicetify-nix.legacyPackages.${final.system};
      };

      overrides = final: prev: {
        # remove gnome from dependencies
        xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (prevAttrs: {
          buildInputs = builtins.filter (
            x: x != prev.gnome-desktop && x != prev.gnome-settings-daemon
          ) prevAttrs.buildInputs;
          mesonFlags = [ "-Dwallpaper=disabled" ];
        });

        # use nightly quickshell
        inherit (inputs.dank-material-shell.packages.${prev.system}) quickshell;
      };

      inherit (inputs.niri.overlays) niri;
      fenix = inputs.fenix.overlays.default;
    };
  };
}
