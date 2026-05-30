{
  inputs,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.trivial) importJSON;
  inherit (lib.modules) importApply;
in {
  imports = [
    (importApply (inputs.catppuccin + "/modules/global.nix") {
      catppuccinModules =
        [./limine.nix ./tty.nix] ++ (map (m: inputs.catppuccin + "/modules/nixos/${m}.nix") ["plymouth" "sddm"]);
    })
  ];

  options.catppuccin.palette = mkOption {
    description = "Global Catppuccin palette";
    inherit (pkgs.formats.json {}) type;
    readOnly = true;
  };

  config.catppuccin = {
    sources.firefox = options.catppuccin.sources.default.firefox.overrideAttrs {
      patches = [./../../../res/catppuccin/firefox-write-themes-to-json.patch];
      installPhase = ''mkdir -p $out; mv themes/* $out'';
    };
    palette = importJSON ./../../../res/catppuccin/palette.json;
  };
}
