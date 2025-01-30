{
  lib,
  buildGoModule,
  fetchFromGitLab,
}:

buildGoModule rec {
  pname = "find-my-device-server";
  version = "0.8.0";

  src = fetchFromGitLab {
    owner = "Nulide";
    repo = "findmydeviceserver";
    tag = "v${version}";
    hash = "sha256-VU+0udOKG5MLyFKDEjTc+OzGalcXJWBAWWuX66rSpaM=";
  };

  vendorHash = "sha256-2BAI2ScF6jeeShsR5ZTBkAOTcY/GvorC6l3ifpO3TCM=";

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mkdir -p $out/share/findmydeviceserver
    cp -r $src/web/* $out/share/findmydeviceserver
  '';

  meta = {
    description = "A server to communicate with the FMD Android app, to locate and control your devices";
    homepage = "https://gitlab.com/Nulide/findmydeviceserver";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ PopeRigby ];
    mainProgram = "findmydeviceserver";
  };
}
