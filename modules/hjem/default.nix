rec {
  # keep-sorted start block=true
  catppuccin = {...}: {
    imports = [./catppuccin];
    _class = "hjem";
  };
  presets = {lib, ...}: {
    imports = lib.fileset.toList (lib.fileset.fileFilter (file: file.hasExt "nix") ./presets);
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
  stefan = {
    lib,
    inputs,
    ...
  }: {
    imports =
      [catppuccin presets rum-extensions sops inputs.secrets.hjemModules.stefan inputs.hjem-rum.hjemModules.default]
      ++ lib.filesystem.listFilesRecursive ./stefan;
    _class = "hjem";
  };
  # keep-sorted end
}
