{
  self,
  inputs,
  lib,
  ...
}:

{
  flake = {
    nixCfg = {
      nix = {
        settings = {
          trusted-users = [
            "root"
            "@wheel"
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          auto-optimise-store = true;
          use-xdg-base-directories = true;
          allow-import-from-derivation = false;
          warn-dirty = false;
        };

        # add each flake input as a registry
        # to make nix3 commands consistent with the flake
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      };

      nixpkgs = {
        overlays = builtins.attrValues self.overlays;
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
      };
    };
  };

  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (self.nixCfg.nixpkgs) config overlays;
      };
    };
}
