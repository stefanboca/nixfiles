{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kache";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OWtSDC6r7TOekyopc3hPbDh75O9V+DU+YgsVV8nCnjg=";
  };

  cargoHash = "sha256-0wY1EQ69AB4tdkVqGhQw3FoKU6qAr9WlW+pcVHKDfT8=";

  cargoBuildFlags = ["-p" "kache"];
  doCheck = false;

  meta = {
    description = "Zero-copy, content-addressed build cache for Rust, C/C++ and more";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    mainProgram = "kache";
  };
})
