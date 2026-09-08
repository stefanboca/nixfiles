{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kache";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M0L0B4/Gom2hT19XAHFclDOPbylN8dpjNXsEsuGgHjU=";
  };

  cargoHash = "sha256-M3beojPbL5tOUvhn7jxQ8o/N1lh9e5paaf9T45cI7nw=";

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
