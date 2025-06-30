{
  buildGoModule,
  fetchFromGitHub,
  lib,
  stdenv,
  nodejs,
  pnpm,
  rustc,
  wasm-bindgen-cli_0_2_93,
  wasm-pack,
  rustPlatform,
  binaryen,
}:

let
  pname = "note-mark";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "enchant97";
    repo = "note-mark";
    rev = "v${version}";
    hash = "sha256-Sx9kFLDfWt2RFzjQNkg1eg8LB5h5DjcHz1v/Q8MRzKU=";
  };

  renderer = rustPlatform.buildRustPackage {
    pname = "${pname}-frontend-renderer";
    inherit version src;

    sourceRoot = "${src.name}/frontend/renderer";

    cargoHash = "sha256-JJizLulfxFvvAkG9qRKCN9Lj2KklWjbVAdOT9nuQIko=";

    nativeBuildInputs = [
      wasm-bindgen-cli_0_2_93
      wasm-pack
      rustc.llvmPackages.lld
      binaryen
    ];

    buildPhase = ''
      HOME=$(mktemp -d)
      wasm-pack build . --target bundler
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r pkg/* $out

      runHook postInstall
    '';
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "${pname}-frontend";
    inherit version src;

    sourceRoot = "${finalAttrs.src.name}/frontend";

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      hash = "sha256-HyHkfVgiryBGx5zr+REAJ0Z0aFT2vvQ0XYFdRnCHVQY=";
    };

    installPhase = ''
      runHook preInstall

      pnpm install --frozen-lockfile

      cp -r ${renderer} renderer/pkg
      pnpm run build

      mkdir -p $out
      cp -r dist/* $out/

      runHook postInstall
    '';
  });
in
buildGoModule (finalAttrs: {
  inherit pname version src;

  sourceRoot = "${finalAttrs.src.name}/backend";

  vendorHash = "sha256-SHchv8/NyZ6F71dhZ+O3sudcUs5h0zBbX2dRN1hLMS8=";

  ldflags = [
    "-s"
    "-w"
  ];

  installPhase = ''
    runHook preInstall

    # Install the Go binary
    install -Dm755 $GOPATH/bin/backend $out/bin/note-mark

    # Copy frontend static files
    mkdir -p $out/static
    cp -r ${frontend}/* $out/static/

    runHook postInstall
  '';

  meta = {
    description = "Note Mark is a lighting fast and minimal; web-based Markdown notes app";
    homepage = "https://github.com/enchant97/note-mark";
    changelog = "https://github.com/enchant97/note-mark/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ PopeRigby ];
    mainProgram = "note-mark";
    platforms = lib.platforms.all;
  };
})
