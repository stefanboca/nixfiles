inputs: {
  default = final: _prev: import ./pkgs final;

  firefox-nightly = final: prev: {
    inherit (inputs.firefox-nightly.overlays.default final prev) firefox-beta-bin firefox-devedition-bin firefox-esr-bin firefox-nightly-bin;
  };

  spicetify = final: _prev: {
    spicePkgs = import (inputs.spicetify-nix + "/pkgs") final;
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
  xwayland-satellite = inputs.xwayland-satellite.overlays.default;
  # keep-sorted end
}
