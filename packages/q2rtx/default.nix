{
  cmake,
  fetchFromGitHub,
  lib,
  python3,
  stdenv,
  zlib,
  libGL,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation rec {
  pname = "q2rtx";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "Q2RTX";
    rev = "v${version}";
    hash = "sha256-ClOkkKCdtkX0K8Wr9+6EpiMZ9AVsLkZuFr285UMjYFU=";
    fetchSubmodules = true;
  };

  buildInputs = [
    python3
    zlib
    libGL
    vulkan-headers
    vulkan-loader
  ];

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "NVIDIA’s implementation of RTX ray-tracing in Quake II";
    homepage = "https://github.com/NVIDIA/Q2RTX";
    changelog = "https://github.com/NVIDIA/Q2RTX/blob/${src.rev}/changelog.md";
    license = lib.licenses.gpl2;
    mainProgram = "q2rtx";
  };
}
