{...}: {
  projectRootFile = "flake.nix";
  programs = {
    deadnix.enable = true;
    keep-sorted.enable = true;
    alejandra.enable = true;
  };
}
