{
  atk,
  cairo,
  cargo-tauri,
  darwin,
  fetchFromGitHub,
  fetchNpmDeps,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libsoup_3,
  nodejs,
  npmHooks,
  openssl,
  pango,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage rec {
  pname = "dar2oar";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "SARDONYX-sard";
    repo = "dar-to-oar";
    rev = "bd7f82269d74ae6dd68d14f74581aad9a5fe43e2";
    hash = "sha256-3Af3LCZ4r+3TpbIp75urlbvSzw2FHTgnsPg6J7dvFcs=";
  };

  cargoHash = "sha256-6tU3mT5I4pBdjnzgzBHnQaKuMbCgCfpBJLi1F6Walkg=";

  npmDeps = fetchNpmDeps {
    inherit src;
    sourceRoot = src.name;
    hash = "sha256-r0/qKbJnmehtF1cyabXUemYZKggU12N6Fs21DY9kSO8=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook3
  ];

  buildInputs =
    [
      atk
      cairo
      gdk-pixbuf
      glib
      gtk3
      libsoup_3
      openssl
      pango
      webkitgtk_4_1
    ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk.framework;
      [
        AppKit
        CoreGraphics
        Foundation
      ]
    )
    ++ lib.optionals stdenv.isLinux [
      wayland
    ];

  meta = {
    description = "Dynamic Animation Replacer to Open Animation Replacer converter for Skyrim SE";
    homepage = "https://github.com/SARDONYX-sard/dar-to-oar.git";
    changelog = "https://github.com/SARDONYX-sard/dar-to-oar/blob/${src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "dar2oar";
  };
}
