{
  base = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./base;
    _class = "nixos";
  };
  desktop = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./desktop;
    _class = "nixos";
  };
  theming = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./theming;
    _class = "nixos";
  };
}
