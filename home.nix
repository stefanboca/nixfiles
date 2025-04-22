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
  programs.home-manager.enable = true;

  xdg.enable = true;

  # TODO: enable on nixos
  # nix.package = pkgs.nix;
  # nix.settings.use-xdg-base-directories = true;

  # TODO: remove on nixos
  nixGL.packages = inputs.nixgl.packages;
  nixGL.vulkan.enable = true;

  stylix.enable = true;
  # TODO: more themes
  stylix.base16Scheme = {
    slug = "tokyonight_moon";
    scheme = "Tokyonight Moon";
    base00 = "#222436";
    base01 = "#3b4261";
    base02 = "#636da6";
    base03 = "#636da6";
    base04 = "#fca7ea";
    base05 = "#c8d3f5";
    base06 = "#b4f9f8";
    base07 = "#c8d3f5";
    base08 = "#ff757f";
    base09 = "#ff966c";
    base0A = "#ffc777";
    base0B = "#c3e88d";
    base0C = "#86e1fc";
    base0D = "#82aaff";
    base0E = "#c099ff";
    base0F = "#0db9d7";
  };
  stylix.targets.gtk.flatpakSupport.enable = false;
  stylix.targets.neovim.enable = false;

  fonts.fontconfig.enable = true;
  stylix.fonts = {
    monospace = {
      package = pkgs.lilex;
      name = "Lilex";
    };
    # TODO: find a good serif font
    sansSerif = {
      package = pkgs.open-sans;
      name = "Open Sans";
    };

    sizes = {
      terminal = 10;
      desktop = 11;
      popups = 11;
      applications = 11;
    };
  };
}
