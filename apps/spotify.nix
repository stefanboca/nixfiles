{
  config,
  inputs,
  pkgs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  # TODO: stylix overrides
  programs.spicetify = {
    # enable = true; # see note below
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      bookmark
    ];
  };

  # NOTE: manually add package in order to wrap with nixGL
  # TODO: remove on nixos
  home.packages = [
    (config.lib.nixGL.wrap config.programs.spicetify.spicedSpotify)
  ];
}
