{ self, inputs, ... }:

let
  allNixos = import ../nixos;
  allHomeManager = import ../home-manager;

  homeCommon = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-index-database.homeModules.nix-index
    inputs.sops-nix.homeManagerModules.sops
    inputs.spicetify-nix.homeManagerModules.spicetify

    # shared nixpkgs config for home-manager
    { inherit (self.nixCfg) nix; }
  ]
  ++ builtins.attrValues allHomeManager;

  nixosCommon = [
    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.home-manager
    inputs.niri.nixosModules.niri
    inputs.sops-nix.nixosModules.sops

    ../../hosts/common

    # share nix and nixpkgs config with home-manager
    {
      inherit (self.nixCfg) nix nixpkgs;
      home-manager = {
        extraSpecialArgs = { inherit self inputs; };
        sharedModules = homeCommon;
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
      };
    }

    # share select config with home-manager
    (
      { config, lib, ... }:
      {
        home-manager.sharedModules = [
          {
            config.theming = {
              inherit (config.theming)
                enable
                flavor
                accent
                fonts
                ;
            };
          }
        ];
      }
    )
  ]
  ++ builtins.attrValues allNixos;
in
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake = {
    nixosModules = {
      common = nixosCommon;

      # TODO: find a better hostname
      laptop.imports =
        with inputs.nixos-hardware.nixosModules;
        [
          ../../hosts/laptop/default.nix

          asus-battery
          common-cpu-intel
          common-gpu-intel
          common-gpu-nvidia
          common-pc-ssd

          inputs.disko.nixosModules.disko
        ]
        ++ nixosCommon;
    }
    // allNixos;

    homeModules = {
      common = homeCommon;
    }
    // allHomeManager;
  };
}
