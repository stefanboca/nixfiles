{
  description = "Home Manager configuration of doctorwho";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: remove on nixos
    nixGL.url = "github:nix-community/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    catppuccin-fish.url = "github:catppuccin/fish";
    catppuccin-fish.flake = false;
    # TODO: remove once https://github.com/folke/tokyonight.nvim/pull/716 is merged, and use pkgs.vimPlugins.tokyonight-nvim instead
    tokyonight-nvim.url = "github:stefanboca/tokyonight.nvim";
    tokyonight-nvim.flake = false;

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: use nixpkgs ghostty on 1.1.4 release
    # use nightly for now because of strange goto_split behavior
    ghostty.url = "github:ghostty-org/ghostty/76a3612195bb3d67e67a1e824fb3cbdb4d339735";
    ghostty.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # NOTE: pinned to avoid recompiling, needs manual update
    emmylua-analyzer-rust.url = "github:EmmyLuaLs/emmylua-analyzer-rust/a796be0c2dbf14780140d6c2c06377dfc0728dd9";
    emmylua-analyzer-rust.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      flake-parts,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/flake/modules.nix
        ./modules/flake/nix.nix
        ./modules/flake/overlays.nix
        ./modules/flake/packages.nix
        ./modules/flake/shell.nix
      ];

      systems = [ "x86_64-linux" ];

      flake = {
        nixosConfigurations = {
          # TODO: find a better hostname
          laptop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ self.nixosModules.laptop ];
          };
        };

        # TODO: remove on nixos
        homeConfigurations = {
          doctorwho =
            let
              pkgs = import inputs.nixpkgs {
                system = "x86_64-linux";
                inherit (self.nixCfg.nixpkgs) config overlays;
              };
            in
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ self.homeModules.doctorwho ];
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
