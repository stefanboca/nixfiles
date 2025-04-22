{
  description = "Home Manager configuration of doctorwho";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: remove on nixos
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: use nixpkgs ghostty on 1.1.4 release
    # use nightly for now because of strange goto_split behavior
    ghostty.url = "github:ghostty-org/ghostty?ref=7ef9c24e3f200342b13be777718f1cf278dca1eb";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emmylua-analyzer-rust = {
      # NOTE: pinned to avoid recompiling, needs manual update
      url = "github:EmmyLuaLs/emmylua-analyzer-rust?ref=e112a77406ee982be94e6eb049d46e45255de19e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          inputs.fenix.overlays.default
          inputs.ghostty.overlays.default
        ];
      };
    in
    {
      homeConfigurations.doctorwho = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.stylix.homeManagerModules.stylix
          ./home.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      formatter.${pkgs.system} = pkgs.nixfmt-tree;
    };
}
