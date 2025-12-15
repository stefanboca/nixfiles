{
  # keep-sorted start block=true
  catppuccin = {...}: {
    imports = [./catppuccin];
    _class = "nixos";
  };
  extensions = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./extensions;
    _class = "nixos";
  };
  presets = {lib, ...}: {
    imports = lib.filesystem.listFilesRecursive ./presets;
    _class = "nixos";
  };
  # keep-sorted end
}
