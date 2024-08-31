{
    cmake,
    fetchFromGitHub,
    lib,
    makeWrapper,
    ninja,
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

    nativeBuildInputs = [
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

        runHook postInstall
    '';

    postFixup = ''
        patchelf \
            --add-needed ${pkgs.libGL}/lib/libGL.so.1 \
            $out/bin/tacentview

        # So Tacent View can find its assets
        wrapProgram $out/bin/tacentview \
            --set NIX_DATA_DIR $out
    '';

    meta = {
        description = "An image and texture viewer";
        homepage = "https://github.com/bluescan/tacentview";
        license = lib.licenses.isc;
        mainProgram = pname;
    };
}
