{
  base = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./base;};
  cli = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./cli;};
  desktop = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./desktop;};
  theming = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./theming;};
}
