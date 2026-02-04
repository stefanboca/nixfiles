{...}: {
  projectRootFile = "flake.nix";
  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    fish_indent.enable = true;
    keep-sorted.enable = true;
  };
}
