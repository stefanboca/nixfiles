{
  presets = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./rum;};
  rum-extensions = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./rum;};
  sops = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./sops;};
}
