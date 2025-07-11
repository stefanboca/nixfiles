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

      overrides = final: prev: {
        # remove gnome from dependencies
        xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (prevAttrs: {
          buildInputs = builtins.filter (
            x: x != prev.gnome-desktop && x != prev.gnome-settings-daemon
          ) prevAttrs.buildInputs;
          mesonFlags = [ "-Dwallpaper=disabled" ];
        });

      };

      inherit (inputs.niri.overlays) niri;
      fenix = inputs.fenix.overlays.default;
      ghostty = inputs.ghostty.overlays.default;
    };
  };
}
