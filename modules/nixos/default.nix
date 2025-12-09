{
  # keep-sorted start block=true
  base = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./base;
    _class = "nixos";
  };
  catppuccin = {...}: {
    imports = [./catppuccin];
    _class = "nixos";
  };
  desktop = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./desktop;
    _class = "nixos";
  };
  presets = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./presets;
    _class = "nixos";
  };
  theming = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./theming;
    _class = "nixos";
  };
  # keep-sorted end
}
