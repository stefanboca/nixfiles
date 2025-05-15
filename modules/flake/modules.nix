{ self, inputs, ... }:

let
  allNixos = import ../nixos;
  allHomeManager = import ../home-manager;

  extraArgs =
    { pkgs, ... }:
    {
      _module.args = {
        inherit self inputs;
      };
    };

  homeCommon = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.stylix.homeManagerModules.stylix

    extraArgs

    # shared nixpkgs config for home-manager
    { config = { inherit (self.nixCfg) nix; }; }
  ] ++ builtins.attrValues allHomeManager;

  nixosCommon = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ../../hosts/common

    extraArgs

    # shared nixpkgs config for home-manager
    {
      config = {
        inherit (self.nixCfg) nix nixpkgs;
        home-manager = {
          sharedModules = homeCommon;
          useGlobalPkgs = true;
          useUserPackages = true;
        };
      };
    }
  ] ++ builtins.attrValues allNixos;
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
    } // allNixos;

    # TODO: remove on nixos
    homeManagerModules = {
      common = homeCommon;

      doctorwho.imports = [
        ../../home/stefan/laptop.nix

        (
          { pkgs, ... }:
          {
            nix.package = pkgs.nix;
            home.username = "doctorwho";
            home.homeDirectory = "/home/doctorwho";
            nixGL.packages = inputs.nixGL.packages;
            nixGL.vulkan.enable = true;
          }
        )
      ] ++ homeCommon;
    } // allHomeManager;
  };
}
