{
  presets = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./presets;
    _class = "hjem";
  };
  rum-extensions = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./rum;
    _class = "hjem";
  };
  sops = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./sops;
    _class = "hjem";
  };
  catppuccin = {lib, ...}: {
    imports = [./catppuccin];
    _class = "hjem";
  };
}
