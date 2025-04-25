{
  description = "Home Manager configuration of doctorwho";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: remove on nixos
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin-fish.url = "github:catppuccin/fish";
    catppuccin-fish.flake = false;
    # TODO: remove once https://github.com/folke/tokyonight.nvim/pull/716 is merged, and use pkgs.vimPlugins.tokyonight-nvim instead
    tokyonight-nvim.url = "github:stefanboca/tokyonight.nvim";
    tokyonight-nvim.flake = false;

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: use nixpkgs ghostty on 1.1.4 release
    # use nightly for now because of strange goto_split behavior
    ghostty.url = "github:ghostty-org/ghostty?ref=4e91d11a60bf3f52a15936cef65eae7135906b28";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # NOTE: pinned to avoid recompiling, needs manual update
    emmylua-analyzer-rust.url = "github:EmmyLuaLs/emmylua-analyzer-rust?ref=117e344eef8c3cd1ab9cfd3ee5ca332b9a19fe0e";
    emmylua-analyzer-rust.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      home-manager,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        home-manager.flakeModules.home-manager
        ./modules/flake/modules.nix
        ./modules/flake/nix.nix
        ./modules/flake/overlays.nix
      ];

      systems = [ "x86_64-linux" ];

      flake = {
        homeConfigurations = {
          doctorwho = home-manager.lib.homeManagerConfiguration {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              inherit (self.nixCfg.nixpkgs) config overlays;
            };
            modules = [ self.homeManagerModules.doctorwho ];
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
          formatter = pkgs.nixfmt-tree;
        };
    };
}
