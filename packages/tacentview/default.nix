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
        rev = "409049e41fd2e77540c7b875c368ddbbecf883fa";
        hash = "sha256-5uAAYpyquidzbsnLBmV9hpZcUI8vtxW0uLcM/knMnEQ=";
    };

    nativeBuildInputs = with pkgs; [
        cmake
        ninja
        makeWrapper
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

        mkdir -p $out/tacentview
        cp -r ../Assets/ -t $out/tacentview/

        mkdir -p $out/share
        cp -r ../Linux/deb_template/usr/share/icons $out/share
        cp -r ../Linux/deb_template/usr/share/applications $out/share

        runHook postInstall
    '';

    postFixup = ''
        patchelf \
            --add-needed ${pkgs.libGL}/lib/libGL.so.1 \
            $out/bin/tacentview

        # So Tacent View can find its assets
        wrapProgram $out/bin/tacentview \
            --set NIX_DATA_DIR $out

        substituteInPlace $out/share/applications/tacentview.desktop \
            --replace "tacentview.png" "tacentview"
    '';

    meta = {
        description = "An image and texture viewer";
        homepage = "https://github.com/bluescan/tacentview";
        license = lib.licenses.isc;
        maintainers = [ lib.maintainers.PopeRigby ];
        mainProgram = pname;
    };
}
