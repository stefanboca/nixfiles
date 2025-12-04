{
  inputs,
  lib,
  self,
}: let
  inherit (lib.attrsets) attrValues;

  inherit (inputs.disko.nixosModules) disko;
  inherit (inputs.home-manager.nixosModules) home-manager;
  inherit (inputs.niri.nixosModules) niri;
  inherit (inputs.sops-nix.nixosModules) sops;
  hjem = inputs.hjem.nixosModules.default;
  nixosHardware = inputs.nixos-hardware.nixosModules;
in {
  # TODO: find a better hostname
  laptop = lib.nixosSystem {
    specialArgs = {inherit inputs self;};
    modules =
      [
        disko
        home-manager
        niri
        sops

        nixosHardware.asus-battery
        nixosHardware.common-cpu-intel
        nixosHardware.common-gpu-nvidia
        nixosHardware.common-pc-ssd

        ./common
        ./laptop

        {
          home-manager.sharedModules =
            [
              inputs.dank-material-shell.homeModules.dankMaterialShell.default
              inputs.dank-material-shell.homeModules.dankMaterialShell.niri
              inputs.nix-index-database.homeModules.nix-index
              inputs.sops-nix.homeManagerModules.sops
              inputs.spicetify-nix.homeManagerModules.spicetify
            ]
            ++ attrValues self.homeModules;
        }
      ]
      ++ attrValues self.nixosModules;
  };

  vm = lib.nixosSystem {
    specialArgs = {inherit inputs self;};
    modules = [
      hjem

      ./vm
    ];
  };
}
