{pkgs, ...}: {
  asus-nb-wmi-kernel-module = pkgs.callPackage ./asus-nb-wmi-kernel-module.nix {};
  bencher = pkgs.callPackage ./bencher.nix {};
}
