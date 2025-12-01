{lib, ...}: {
  imports = lib.filesystem.listFilesRecursive ./programs;
}
