{
  rum-extensions = {lib, ...}: {imports = lib.filesystem.listFilesRecursive ./rum;};
}
