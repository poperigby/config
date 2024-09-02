{
    fetchFromGitHub,
    lib,
    pkgs,
    stdenv,
}:

stdenv.mkDerivation rec {
    pname = "tacentview";
    version = "1.0.44";

    src = fetchFromGitHub {
        owner = "bluescan";
        repo = pname;
        rev = "a863c4bbe36dc3975fde8dfc731316b39f0a9217";
        hash = "sha256-jM8mk4D4jWXIJbOaVlHFzM/Z8rBlpV52yomfte3Fj9Y=";
    };

    nativeBuildInputs = with pkgs; [
        cmake
        ninja
    ];

    buildInputs = with pkgs; [
        libGL
        poperigby.tacent
        xorg.libX11
        xorg.libxcb
        zenity
    ];

    cmakeFlags = [
        "-DFETCHCONTENT_SOURCE_DIR_TACENT=${pkgs.poperigby.tacent.src}"
        "-DPACKAGE_NIX=True"
    ];

    installPhase = ''
        runHook preInstall

        install -D tacentview -t $out/bin

        mkdir -p $out/share/tacentview
        cp -r ../Assets/* -t $out/share/tacentview/
        cp -r ../Linux/deb_template/usr/share/icons $out/share
        cp -r ../Linux/deb_template/usr/share/applications $out/share

        runHook postInstall
    '';

    postFixup = ''
        patchelf --add-needed ${pkgs.libGL}/lib/libGL.so.1 $out/bin/tacentview
    '';

    meta = {
        description = "An image and texture viewer";
        homepage = "https://github.com/bluescan/tacentview";
        license = lib.licenses.isc;
        maintainers = [ lib.maintainers.PopeRigby ];
        mainProgram = pname;
    };
}
