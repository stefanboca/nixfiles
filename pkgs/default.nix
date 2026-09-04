pkgs: {
  # keep-sorted start block=yes newline_separated=yes
  asus-nb-wmi-kernel-module = pkgs.callPackage ./asus-nb-wmi-kernel-module {};

  calfnxt = pkgs.callPackage ./calfnxt {};

  kache = pkgs.callPackage ./kache {};
  # keep-sorted end
}
