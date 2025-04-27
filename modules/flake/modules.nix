{ self, inputs, ... }:

let
  allNixos = import ../nixos;
  allHomeManager = import ../home-manager;

  extraArgs =
    { pkgs, ... }:
    {
      _module.args = { inherit self inputs; };
    };

  homeCommon = [
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.stylix.homeManagerModules.stylix

    extraArgs

    # shared nixpkgs config for home-manager
    { config = { inherit (self.nixCfg) nix; }; }
  ] ++ builtins.attrValues allHomeManager;

  nixosCommon = [
    inputs.home-manager.nixosModules.home-manager

    ../../hosts/common

    extraArgs

    # shared nixpkgs config for home-manager
    {
      config = {
        inherit (self.nixCfg) nix nixpkgs;
        home-manager = {
          sharedModules = homeCommon;
          useGlobalPkgs = true;
        };
      };
    }
  ] ++ builtins.attrValues allNixos;
in
{
  flake = {
    nixosModules = {
      common = nixosCommon;

      # TODO: find a better hostname
      laptop.imports = [ ] ++ nixosCommon;
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
            programs.nh.flake = "/home/doctorwho/.config/home-manager";
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
