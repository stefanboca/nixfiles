{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./apps
    ./terminal
  ];
  home.username = "doctorwho";
  home.homeDirectory = "/home/doctorwho";
  home.preferXdgDirectories = true;
  home.stateVersion = "25.05";

  xdg.enable = true;

  # TODO: enable on nixos
  # nix.package = pkgs.nix;
  # nix.settings.use-xdg-base-directories = true;

  nixGL.packages = inputs.nixgl.packages;
  nixGL.vulkan.enable = true;
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.lilex # lilex font
  ];
}
