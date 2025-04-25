{ self, inputs, ... }:

let
  allHomeManager = import ../home-manager;

  extraArgs =
    { pkgs, ... }:
    {
      _module.args = {
        inherit self inputs;
        inherit (pkgs) system;
      };
    };

  homeCommon = [
    inputs.spicetify-nix.homeManagerModules.spicetify
    inputs.stylix.homeManagerModules.stylix

    extraArgs

    # shared nixpkgs config for home-manager
    { config = { inherit (self.nixCfg) nix; }; }
  ] ++ builtins.attrValues allHomeManager;
in
{
  flake = {
    homeManagerModules = {
      common = homeCommon;

      doctorwho.imports = [ ../../home.nix ] ++ homeCommon;
    } // allHomeManager;
  };
}
