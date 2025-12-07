{
  base = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./base;
    _class = "homeManager";
  };
  cli = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./cli;
    _class = "homeManager";
  };
  desktop = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./desktop;
    _class = "homeManager";
  };
  theming = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./theming;
    _class = "homeManager";
  };
}
