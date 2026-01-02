{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    # FIXME: remove once https://github.com/NixOS/nixpkgs/pull/476347 reaches nixos-unstable
    nixpkgs-476347.url = "github:NixOS/nixpkgs/pull/476347/head";
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

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    dank-material-shell.url = "github:AvengeMedia/DankMaterialShell";
    dank-material-shell.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";

    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";
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
      };
    };

    autocpu = {
      url = "github:stefanboca/autocpu";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    inherit (lib.attrsets) attrValues filterAttrs genAttrs mapAttrs' nameValuePair;
    inherit (lib.trivial) pipe;

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = attrValues self.overlays;
      };

    systems = ["x86_64-linux"];
    forAllSystems = f: genAttrs systems (system: f (mkPkgs system));

    treefmt = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
  in {
    nixosConfigurations = import ./hosts {inherit inputs lib self;};

    hjemModules = import ./modules/hjem;
    nixosModules = import ./modules/nixos;

    overlays = import ./overlays.nix inputs;
    packages = forAllSystems (pkgs: import ./pkgs pkgs);

    devShells = forAllSystems (pkgs: import ./dev-shells.nix pkgs);

    templates = import ./templates;

    formatter = forAllSystems (pkgs: treefmt.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);

    checks = forAllSystems (pkgs: let
      inherit (pkgs.stdenv.hostPlatform) system;

      nixosMachines = pipe self.nixosConfigurations [
        (filterAttrs (_: c: c.pkgs.stdenv.hostPlatform.system == system))
        (mapAttrs' (n: c: nameValuePair "nixos-${n}" c.config.system.build.toplevel))
      ];
      packages = mapAttrs' (n: nameValuePair "package-${n}") self.packages.${system};
      devShells = mapAttrs' (n: nameValuePair "devShell-${n}") self.devShells.${system};
      formatting = {formatting = treefmt.${system}.config.build.check self;};
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
