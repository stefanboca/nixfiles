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

  firefox-nightly = final: prev: let
    overlay = inputs.firefox-nightly.overlays.default final prev;
  in {
    inherit (overlay) firefox-esr-bin firefox-beta-bin firefox-devedition-bin firefox-nightly-bin;
  };

  zed-editor = final: prev: {
    zed-editor = (inputs.zed-editor.overlays.default final prev).zed-editor.overrideAttrs (oldAttrs: {
      env = (oldAttrs.env or {}) // {LK_CUSTOM_WEBRTC = final.livekit-libwebrtc;};
      cargoArtifacts = oldAttrs.cargoArtifacts.overrideAttrs (oldAttrs': {
        env = (oldAttrs'.env or {}) // {LK_CUSTOM_WEBRTC = final.livekit-libwebrtc;};
      });
    });
  };

  # keep-sorted start
  blink-cmp = inputs.snv.inputs.blink-cmp.overlays.default;
  blink-lib = inputs.snv.inputs.blink-lib.overlays.default;
  blink-pairs = inputs.snv.inputs.blink-pairs.overlays.default;
  fenix = inputs.fenix.overlays.default;
  ghostty = inputs.ghostty.overlays.default;
  niri = inputs.niri.overlays.default;
  noctalia-shell = inputs.noctalia-shell.overlays.default;
  snv = inputs.snv.overlays.default;
  spicetify = final: _prev: {spicePkgs = inputs.spicetify-nix.legacyPackages.${final.stdenv.hostPlatform.system};};
  xwayland-satellite = inputs.xwayland-satellite.overlays.default;
  # keep-sorted end
}
