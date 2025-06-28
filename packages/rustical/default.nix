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
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "lennart-k";
    repo = "rustical";
    rev = "v${version}";
    hash = "sha256-/dNG/rgDRdqvJVih+8QvXVJb1lFRycgYETy4d1iQVGM=";
  };

  cargoHash = "sha256-IWxAQcagETuwN1j4kGmE1p2cO0SJPhdcIXgX8SjAg4c=";

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
