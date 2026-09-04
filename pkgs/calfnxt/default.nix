{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  pkg-config,
  python3,
  gtk3,
  libx11,
  webkitgtk_4_1,
}:

let
  version = "1.4.0";

  vst3sdk = fetchFromGitHub {
    owner = "steinbergmedia";
    repo = "vst3sdk";
    rev = "v3.8.0_build_66";
    fetchSubmodules = true;
    hash = "sha256-9HnDOOiKT0ploNJukk4vcZjBLS5gL4SdvmfFqZJPIxA=";

    postFetch = ''
      rm -rf $out/doc
    '';
  };

  uiDist = fetchurl {
    url = "https://github.com/boomshop/calfnxt/releases/download/v${version}/calfnxt-${version}-ui-dist.tar.xz";
    hash = "sha256-GRHBHi6Mf24UF1QCx2eGWt2xTq/HawkQlGBbEXaX0wQ=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "calfnxt";
  inherit version;

  src = fetchurl {
    url = "https://github.com/boomshop/calfnxt/releases/download/v${finalAttrs.version}/calfnxt-${finalAttrs.version}.tar.gz";
    hash = "sha256-IPSOVGA07G8InKDfjeHdRr+Yz/cmUa0/7yHkgjt3Oos=";
  };

  postUnpack = ''
    tar -xf ${uiDist} -C "$sourceRoot"
  '';

  postPatch = ''
    mkdir -p external
    ln -s ${vst3sdk} external/vst3sdk
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    gtk3
    libx11
    webkitgtk_4_1
  ];

  cmakeFlags = [
    (lib.cmakeBool "CALFNXT_USE_PREBUILT_UI" true)
  ];

  buildPhase = ''
    runHook preBuild
    cmake --build . --parallel "$NIX_BUILD_CORES" --target calfnxt-plugins
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/vst3
    cp -r VST3/Release/*.vst3 $out/lib/vst3/
    runHook postInstall
  '';

  meta = {
    description = "VST3 audio plugin suite and successor to Calf Studio Gear";
    homepage = "https://calfnxt.org";
    changelog = "https://github.com/boomshop/calfnxt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
