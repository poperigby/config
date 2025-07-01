{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

let
  version = "0.7.11-beta";

  src = fetchFromGitHub {
    owner = "gtsteffaniak";
    repo = "filebrowser";
    rev = "v${version}";
    hash = "sha256-ZRnLrDVYmr6TMmi72G6YdqHlqJy29qoZu6GIJMA83GA=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  frontend = buildNpmPackage {
    pname = "filebrowser-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";

    npmDepsHash = "sha256-Us/F0LyyIw4t65wHLeEY8QOXpbwEp9ZPlXi/cQM4vhQ=";

    postPatch = ''
      cp ${./package-lock.json} ./package-lock.json
    '';

    buildPhase = ''
      runHook preBuild

      ./node_modules/.bin/vite build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      mv dist/* $out

      runHook postInstall
    '';

  };
in
buildGoModule {
  pname = "filebrowser";
  inherit version src;

  sourceRoot = "${src.name}/backend";

  vendorHash = "sha256-XCXb52c097hkWM+ey20DjthHN4eHNkmQ9E8ZpUN5JZ8=";

  excludedPackages = [ "tools" ];

  preBuild = ''
    ldflags+=" -X github.com/gtsteffaniak/filebrowser/backend/common/version.CommitSHA=$(cat ../COMMIT)"
    cp -r ${frontend}/* http/embed/
  '';

  postInstall = ''
    cd "$out/bin"
    mv backend filebrowser
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/gtsteffaniak/filebrowser/backend/common/version.Version=v${version}"
  ];

  meta = with lib; {
    description = "Filebrowser is a web application for managing files and directories";
    homepage = "https://filebrowser.org";
    license = licenses.asl20;
    mainProgram = "filebrowser";
  };
}
