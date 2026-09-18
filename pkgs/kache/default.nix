{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kache";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GokpQVFfyHBrwLodVSG9chbNiJCLupzAzM31mnIGFAU=";
  };

  cargoHash = "sha256-OJ5Iqx3LelSzw6uvm7URpZeH6EeNneXzRaE2Uvhp3Lk=";

  cargoBuildFlags = ["-p" "kache"];
  doCheck = false;

  meta = {
    description = "Zero-copy, content-addressed build cache for Rust, C/C++ and more";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    mainProgram = "kache";
    maintainers = with lib.maintainers; [stefanboca];
  };
})
