{
  lib,
  fetchFromGitHub,
  rustPlatform,

  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tombi";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "tombi-toml";
    repo = "tombi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2516aT6zaI5bntjjJ/p/yk0gWW6fzixQx5ESs29aS6Q=";
  };

  cargoHash = "sha256-cVj0dL9vGVm3WPQ5IA2LDxDLHia5T+pLi6rTQxAqoC4=";

  cargoBuildFlags = [ "--package=tombi-cli" ];

  # tests currently rely on internet connectivity
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Feature-Rich TOML Toolkit";
    homepage = "https://tombi-toml.github.io/tombi/";
    changelog = "https://github.com/tombi-toml/tombi/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    mainProgram = "tombi";
  };
})
