{
  lib,
  fetchFromGitHub,
  rustPlatform,

  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "tombi";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "tombi-toml";
    repo = "tombi";
    rev = "v${version}";
    hash = "sha256-n7T8rsVK36b9Jts6EYrk747HNiUM0/G4lRJwC0VciC0=";
  };

  cargoHash = "sha256-qoElQOnODCemO/pynyQgnFUtBMgayzvUM3s1nrlNOaU=";

  cargoBuildFlags = [ "--package=tombi-cli" ];

  # tests currently rely on internet connectivity
  doCheck = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Feature-Rich TOML Toolkit";
    homepage = "https://tombi-toml.github.io/tombi/";
    changelog = "https://github.com/tombi-toml/tombi/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "tombi";
  };
}
