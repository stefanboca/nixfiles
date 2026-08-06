{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kache";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-foSH+N/EhZFbEPD1yFbZDzxv+B2Q7IVEJA0Q4BPsRVQ=";
  };

  cargoHash = "sha256-BnwKnStmG+pqeE06BbD1VwrNFGKd+dX8GhFez5F+1Kc=";

  cargoBuildFlags = ["-p" "kache"];
  doCheck = false;

  meta = {
    description = "Zero-copy, content-addressed build cache for Rust, C/C++ and more";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    mainProgram = "kache";
  };
})
