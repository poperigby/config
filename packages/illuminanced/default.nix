{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "illuminanced";
  version = "unstable-2024-10-22";

  src = fetchFromGitHub {
    owner = "mikhail-m1";
    repo = "illuminanced";
    rev = "ee95f97dc1ed197abe3a7c4f3ad45121a077d3eb";
    hash = "sha256-dilApolbxgl//2YVbd4ITYVNwfCQQ8LPayqmmW5Jhv8=";
  };

  cargoHash = "sha256-93dAMNSM3WJJ+Hpa4MurNTu7ErqfpQgWt9I20MpO7yk=";

  meta = {
    description = "Ambient Light Sensor Daemon for Linux";
    homepage = "https://github.com/mikhail-m1/illuminanced";
    license = lib.licenses.gpl3Only;
    mainProgram = "illuminanced";
  };
}
