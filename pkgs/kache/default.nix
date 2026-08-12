{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kache";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FOn/T7XM7lhYFI8saT3Ntnq+uOeqpZzxk3n3MCcR0Bc=";
  };

  cargoHash = "sha256-x23BWVvI8Uod/U86EbGXmpFOfgbjtzCR6V1GgrBG+7M=";

  cargoBuildFlags = ["-p" "kache"];
  doCheck = false;

  meta = {
    description = "Zero-copy, content-addressed build cache for Rust, C/C++ and more";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    mainProgram = "kache";
  };
})
