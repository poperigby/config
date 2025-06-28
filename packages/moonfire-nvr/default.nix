{
  fetchFromGitHub,
  lib,
  nodejs,
  pkg-config,
  pnpm,
  rustPlatform,
  sqlite,
  stdenv,
  tzdata,
  ...
}:

let
  version = "0.7.21";

  src = fetchFromGitHub {
    owner = "scottlamb";
    repo = "moonfire-nvr";
    rev = "v${version}";
    hash = "sha256-fkWdMFQw414en3dLzq+JulebC5GSuKIUnYIw7a92/uI=";
  };

  ui = stdenv.mkDerivation (finalAttrs: {
    pname = "moonfire-nvr-ui";
    inherit version src;

    sourceRoot = "${finalAttrs.src.name}/ui";

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

      hash = "sha256-vUrVRFa+24nsxOu6h87fgyUSe8ZX2gnvLakpndm4OnQ=";
    };

    installPhase = ''
      runHook preInstall

      pnpm install
      pnpm run build

      mkdir $out
      mv dist/* $out

      runHook postInstall
    '';
  });
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moonfire-nvr";
  inherit version src;

  sourceRoot = "${finalAttrs.src.name}/server";
  cargoHash = "sha256-87iaOOMFpvWBP3Khjrey3pDBGnA7gY01et5xWGWoIlY=";

  buildFeatures = [ "bundled-ui" ];

  nativeBuildsInputs = [ pkg-config ];
  buildInputs = [
    sqlite
    tzdata
  ];

  doCheck = false;

  env = {
    UI_DIST_DIR = ui;
    VERSION = version;
  };

  meta = {
    description = "Security camera network video recorder";
    homepage = "https://github.com/scottlamb/moonfire-nvr";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
})
