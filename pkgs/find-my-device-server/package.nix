{
    lib,
    buildGoModule,
    fetchFromGitLab,
}:

buildGoModule rec {
    pname = "find-my-device-server";
    version = "0.10.0";

    src = fetchFromGitLab {
        owner = "Nulide";
        repo = "findmydeviceserver";
        tag = "v${version}";
        hash = "sha256-tHOBpl+wwjske1e5jNxqvpL45j0VIiaWWogS/EdoD/A=";
    };

    vendorHash = "sha256-Tfr9bZmHOfPpTqI0z2foNwh55E4eG8BVvJ0VV55q4KY=";

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
