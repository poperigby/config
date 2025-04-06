{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "illuminanced";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "mikhail-m1";
    repo = "illuminanced";
    rev = "4c6178c35f672d042bfb8c833f90281e95be1b95";
    hash = "sha256-D0nEPnb1MFMQHJMhJo1ursfsclFG+XInBtFQXs7y0qw=";
  };

  cargoHash = "sha256-66BYq6qsj0oUETWiAm5uyHjOlR1yZm+JIE6bFQ8b9ZY=";

  meta = {
    description = "Ambient Light Sensor Daemon for Linux";
    homepage = "https://github.com/mikhail-m1/illuminanced";
    license = lib.licenses.gpl3Only;
    mainProgram = "illuminanced";
  };
}
