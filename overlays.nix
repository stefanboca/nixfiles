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

  inherit (inputs.niri.overlays) niri;
  autocpu = inputs.autocpu.overlays.default;
  fenix = inputs.fenix.overlays.default;
  firefox-nightly = inputs.firefox-nightly.overlays.default;
  snv = inputs.snv.overlays.default;
  spicetify = final: _prev: {spicePkgs = inputs.spicetify-nix.legacyPackages.${final.stdenv.hostPlatform.system};};
}
