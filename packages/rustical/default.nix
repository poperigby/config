{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  perl,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "rustical";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "lennart-k";
    repo = "rustical";
    rev = "v${version}";
    hash = "sha256-QWuJKEc6hBA2rdbaqdhrah+WyRwVd91Y8/BIOaKlW28=";
  };

  cargoHash = "sha256-dQF+6my+TxZ6niFO5OnLXcPt0LGEymaXE9NqZWU5HJk=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];
  buildInputs = [ openssl ];

  meta = {
    description = "Yet another calendar server aiming to be simple, fast and passwordless";
    homepage = "https://github.com/lennart-k/rustical";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ PopeRigby ];
    mainProgram = "rustical";
  };
}
