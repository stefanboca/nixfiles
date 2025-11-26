{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.theming;
in {
  imports = [
    ../common/theming.nix
    (lib.modules.importApply "${inputs.catppuccin}/modules/global.nix" {
      catppuccinModules = map (m: "${inputs.catppuccin}/modules/nixos/${m}.nix") [
        # keep-sorted start
        "limine"
        "plymouth"
        "sddm"
        "tty"
        # keep-sorted end
      ];
    })
  ];

  config = lib.mkIf cfg.enable {
    catppuccin = {
      sddm = {
        font = cfg.fonts.sansSerif.name;
        fontSize = builtins.toString cfg.fonts.sizes.desktop;
      };
    };

    environment.systemPackages = cfg.fontPackages;

    console = {
      font = cfg.fonts.monospace.name;
      packages = [cfg.fonts.monospace.package];
    };
  };
}
