inputs: {
  default = _final: prev: import ./pkgs prev;

  catppuccin = _final: prev: let
    upstreamSources = (import inputs.catppuccin {pkgs = prev;}).packages;
  in {
    catppuccin-sources =
      upstreamSources
      // {
        firefox = upstreamSources.firefox.overrideAttrs {
          patches = [./res/catppuccin/firefox-write-themes-to-json.patch];
          installPhase = ''mkdir -p $out; mv themes/* $out'';
        };
      };
  };

  autocpu = inputs.autocpu.overlays.default;
  fenix = inputs.fenix.overlays.default;
  firefox-nightly = inputs.firefox-nightly.overlays.default;
  ghostty = inputs.ghostty.overlays.default;
  niri = inputs.niri.overlays.default;
  noctalia-shell = inputs.noctalia-shell.overlays.default;
  snv = inputs.snv.overlays.default;
  spicetify = final: _prev: {spicePkgs = inputs.spicetify-nix.legacyPackages.${final.stdenv.hostPlatform.system};};
  xwayland-satellite = inputs.xwayland-satellite.overlays.default;
}
