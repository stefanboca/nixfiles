{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    secrets.url = "git+https://github.com/stefanboca/nixfiles-secrets";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.rust-overlay.follows = "";
    };
    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";
    noctalia-shell.inputs.nixpkgs.follows = "nixpkgs";

    ghostty = {
      url = "github:ghostty-org/ghostty/tip";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        home-manager.follows = "";
      };
    };

    zed-editor = {
      url = "github:zed-industries/zed?tag=v1.2.x";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.flake = false;

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "";
    };
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hjem.follows = "hjem";
      };
    };

    snv = {
      url = "github:stefanboca/nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        fenix.follows = "fenix";
        treefmt-nix.follows = "";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
    ...
  } @ inputs: let
    inherit (builtins) attrValues;
    inherit (nixpkgs) lib;
    inherit (lib.attrsets) filterAttrs genAttrs mapAttrs' nameValuePair;

    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = genAttrs systems;
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = removeAttrs self.overlays ["default"] |> attrValues;
      });
    treefmtFor = forAllSystems (system: treefmt-nix.lib.evalModule nixpkgsFor.${system} ./treefmt.nix);
  in {
    nixosConfigurations = import ./hosts {inherit inputs lib self;};
    hjemModules = import ./modules/hjem;
    nixosModules = import ./modules/nixos;

    packages = forAllSystems (system: import ./pkgs nixpkgsFor.${system});
    overlays = import ./overlays.nix inputs;

    devShells = forAllSystems (system: import ./dev-shells.nix nixpkgsFor.${system});
    templates = import ./templates;

    formatter = forAllSystems (system: treefmtFor.${system}.config.build.wrapper);

    checks = forAllSystems (system: let
      nixosMachines =
        self.nixosConfigurations
        |> filterAttrs (_: c: c.pkgs.stdenv.hostPlatform.system == system)
        |> mapAttrs' (n: c: nameValuePair "nixos-${n}" c.config.system.build.toplevel);
      packages = mapAttrs' (n: nameValuePair "package-${n}") self.packages.${system};
      devShells = mapAttrs' (n: nameValuePair "devShell-${n}") self.devShells.${system};
      formatting = {formatting = treefmtFor.${system}.config.build.check self;};
    in
      nixosMachines // packages // devShells // formatting);
  };

  nixConfig = {
    allow-import-from-derivation = false;
    substituters = ["https://cache.nixos.org" "https://nix-community.cachix.org"];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
