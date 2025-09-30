{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = import ../../pkgs {inherit pkgs;};

    overlayAttrs = config.packages;
  };
}
