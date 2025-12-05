{
  self,
  inputs,
  ...
}: let
  allNixos = import ../nixos;
  allHomeManager = import ../home-manager;

  homeCommon =
    [
      inputs.dank-material-shell.homeModules.dankMaterialShell.default
      inputs.dank-material-shell.homeModules.dankMaterialShell.niri
      inputs.nix-index-database.homeModules.nix-index
      inputs.sops-nix.homeManagerModules.sops
      inputs.spicetify-nix.homeManagerModules.spicetify
    ]
    ++ builtins.attrValues allHomeManager;

  nixosCommon =
    [
      inputs.home-manager.nixosModules.home-manager
      inputs.niri.nixosModules.niri
      inputs.sops-nix.nixosModules.sops

      ../../hosts/common

      {
        inherit (self.nixCfg) nix nixpkgs;

        home-manager = {
          extraSpecialArgs = {inherit self inputs;};
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          minimal = true;

          sharedModules = homeCommon;
        };
      }
    ]
    ++ builtins.attrValues allNixos;
in {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.treefmt-nix.flakeModule
  ];

  flake = {
    nixosModules =
      {
        common = nixosCommon;

        # TODO: find a better hostname
        laptop.imports = with inputs.nixos-hardware.nixosModules;
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

    homeModules =
      {
        common = homeCommon;
      }
      // allHomeManager;
  };
}
