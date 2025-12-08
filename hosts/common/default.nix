{
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib.attrsets) attrValues;
in {
  imports = [
    ./users/stefan.nix
  ];

  programs.fish.enable = true;
  users.mutableUsers = false;

  nix = {
    channel.enable = false;
    package = pkgs.nixVersions.latest;
    settings = {
      allowed-users = ["root" "@wheel"];
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true; # don't garbage-collect build-time dependencies
      trusted-users = ["root" "@wheel"];
      use-xdg-base-directories = true;
      warn-dirty = false;

      substituters = ["https://cache.nixos.org" "https://nix-community.cachix.org"];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    registry = {
      n.flake = inputs.nixpkgs;
    };
  };

  nixpkgs = {
    overlays = attrValues self.overlays;
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs self;};
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    minimal = true;
  };
}
