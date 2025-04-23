{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./apps
    ./modules
    ./terminal
  ];
  home.username = "doctorwho";
  home.homeDirectory = "/home/doctorwho";
  home.preferXdgDirectories = true;
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  programs.man.generateCaches = true;

  xdg.enable = true;
  fonts.fontconfig.enable = true;

  # TODO: enable on nixos
  # nix.enable = true;
  # nix.package = pkgs.nix;
  # nix.settings.use-xdg-base-directories = true;

  # TODO: remove on nixos
  nixGL.packages = inputs.nixgl.packages;
  nixGL.vulkan.enable = true;

  theming.enable = true;
  theming.colorscheme = "tokyonight-moon";
}
