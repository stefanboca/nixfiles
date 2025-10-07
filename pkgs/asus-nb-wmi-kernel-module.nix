{
  pkgs,
  lib,
  kernel ? pkgs.linuxPackages_latest.kernel,
}:
pkgs.stdenv.mkDerivation {
  pname = "asus-nb-wmi-kernel-module";
  inherit (kernel) src version postPatch nativeBuildInputs;

  kernelDev = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  moduleDir = "drivers/platform/x86";

  patches = [./0001-screenpad-keys.patch];

  buildPhase = ''
    BUILT_KERNEL=$kernelDev/lib/modules/$kernelVersion/build

    cp $BUILT_KERNEL/Module.symvers .
    cp $BUILT_KERNEL/.config .
    cp $kernelDev/vmlinux .

    make "-j$NIX_BUILD_CORES" modules_prepare
    make "-j$NIX_BUILD_CORES" M=$moduleDir asus-nb-wmi.ko
  '';

  installPhase = ''
    DIR=$out/lib/modules/$kernelVersion/kernel/$moduleDir
    mkdir -p $DIR
    mv $moduleDir/asus-nb-wmi.ko $DIR
  '';

  meta = {
    description = "asus-nb-wmi kernel module";
    license = lib.licenses.gpl3;
  };
}
