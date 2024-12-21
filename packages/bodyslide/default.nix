{
  cmake,
  fetchFromGitHub,
  fetchurl,
  glew,
  lib,
  libGL,
  python312,
  stdenv,
  wxGTK32,
}:

let
  fbxVersion = "202037";
  python = python312.withPackages (packages: [ packages.pexpect ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bodyslide";
  version = "5.7.0";

  srcs = [
    (fetchFromGitHub {
      owner = "ousnius";
      repo = "BodySlide-and-Outfit-Studio";
      tag = finalAttrs.version;
      hash = "sha256-6OZ4ByTCMmZIz6hWbtEH5N3jvWqSYxpoooGB2gdnSag=";
      fetchSubmodules = true;
    })
    (fetchurl {
      url = "https://damassets.autodesk.net/content/dam/autodesk/www/files/fbx${fbxVersion}_fbxsdk_gcc_linux.tar.gz";
      hash = "sha256-GRxrClSfHnAVSgRwXdv1IjLQSablrheAGivCv2C4Tgs=";
    })
  ];

  buildInputs = [
    wxGTK32
    libGL
    glew
  ];

  nativeBuildInputs = [
    cmake
  ];

  postUnpack = # hash
    ''
      mkdir -p ./source/fbxsdk
      ${lib.getExe python} ${./automate_installer.py} ./fbx${fbxVersion}_fbxsdk_linux ./source/fbxsdk
      ls ./source
    '';

  meta = {
    description = "BodySlide and Outfit Studio, a tool to convert, create, and customize outfits and bodies for Bethesda games";
    homepage = "https://github.com/ousnius/BodySlide-and-Outfit-Studio";
    license = lib.licenses.gpl3Only;
    mainProgram = "body-slide";
    platforms = lib.platforms.all;
  };
})
