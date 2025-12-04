{
  base = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./base;};
  desktop = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./desktop;};
  theming = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./theming;};
}
