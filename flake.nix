{
  description = "Home Manager configuration of doctorwho"; # TODO: change

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: remove on nixos
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    stylix = {
      url = "github:danth/stylix";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        git-hooks.follows = "git-hooks";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        systems.follows = "systems";
      };
    };
    catppuccin-fish = {
      url = "github:catppuccin/fish";
      flake = false;
    };
    # TODO: remove once https://github.com/folke/tokyonight.nvim/pull/716 is merged, and use pkgs.vimPlugins.tokyonight-nvim instead
    tokyonight-nvim = {
      url = "github:stefanboca/tokyonight.nvim";
      flake = false;
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    # TODO: use nixpkgs ghostty on 1.1.4 release; nightly for now because of strange goto_split behavior
    ghostty = {
      url = "github:ghostty-org/ghostty/b6f338065eb45935627a51a7d9102019aaeae1c0";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        nixpkgs-unstable.follows = "nixpkgs";
      };
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        hercules-ci-effects.follows = "hercules-ci-effects";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs = {
        flake-compat.follows = "flake-compat";
        lib-aggregate.follows = "lib-aggregate";
        nixpkgs.follows = "nixpkgs";
      };
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emmylua-analyzer-rust = {
      # NOTE: pinned to avoid recompiling, needs manual update
      url = "github:EmmyLuaLs/emmylua-analyzer-rust/011fad400c9476f1dab27b5be18a6f2ed23378d9";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # the following are not used explicitly; we use them to compact the lockfile.
    flake-compat.url = "github:nix-community/flake-compat";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs-lib.follows = "nixpkgs-lib";
      };
    };
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nur = {
      url = "github:nix-community/nur";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
