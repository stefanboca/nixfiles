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

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix/bc6d2b7b57dd29389538f8c4465e408c07187404";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    centerpiece = {
      url = "github:friedow/centerpiece";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # TODO: use nixpkgs ghostty on 1.1.4 release
    # use nightly for now because of strange goto_split behavior
    ghostty.url = "github:ghostty-org/ghostty/92c1f4b0b9c6fde6d8f79109de71bf4e30831e86";
    ghostty.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # NOTE: pinned to avoid recompiling, needs manual update
    emmylua-analyzer-rust.url = "github:EmmyLuaLs/emmylua-analyzer-rust/5e7c78ec71b52636abbc83272c4435236d40cf06";
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
            specialArgs = { inherit self inputs; };
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
