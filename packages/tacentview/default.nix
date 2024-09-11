{
    cmake,
    fetchFromGitHub,
    lib,
    libGL,
    ninja,
    poperigby,
    stdenv,
    xorg,
    zenity,
    ...
}:

stdenv.mkDerivation rec {
    pname = "tacentview";
    version = "1.0.46";

    src = fetchFromGitHub {
        owner = "bluescan";
        repo = pname;
        rev = version;
        hash = "sha256-d4A26p1hmkYEZ+h6kRbHHr4QmAc3PMe3qYdkeKIRGkU=";
    };

    nativeBuildInputs = [
        cmake
        ninja
    ];

    buildInputs = [
        libGL
        poperigby.tacent
        xorg.libX11
        xorg.libxcb
        zenity
    ];

    cmakeFlags = [
        "-DFETCHCONTENT_SOURCE_DIR_TACENT=${poperigby.tacent.src}"
        "-DPACKAGE_NIX=True"
    ];

    installPhase = ''
        runHook preInstall

        install -D tacentview -t $out/bin

        mkdir -p $out/share/tacentview
        cp -r ../Assets $out/share/tacentview/
        cp -r ../Linux/deb_template/usr/share/icons $out/share
        cp -r ../Linux/deb_template/usr/share/applications $out/share

        runHook postInstall
    '';

    postFixup = ''
        patchelf --add-needed ${libGL}/lib/libGL.so.1 $out/bin/tacentview
    '';

    meta = {
        description = "An image and texture viewer";
        homepage = "https://github.com/bluescan/tacentview";
        license = lib.licenses.isc;
        maintainers = [ lib.maintainers.PopeRigby ];
        mainProgram = pname;
    };
}
