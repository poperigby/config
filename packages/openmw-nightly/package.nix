{
    SDL2,
    boost,
    bullet,
    cmake,
    fetchFromGitLab,
    ffmpeg,
    inputs,
    luajit,
    lz4,
    openal,
    openscenegraph,
    pkg-config,
    qt6,
    recastnavigation,
    stdenv,
    unshield,
    wrapQtAppsHook,
    xorg,
    yaml-cpp,
    ...
}:

let
    GL = "GLVND"; # or "LEGACY";

    osg' = (openscenegraph.override { colladaSupport = true; }).overrideDerivation (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
            "-Wno-dev"
            "-DOpenGL_GL_PREFERENCE=${GL}"
            "-DBUILD_OSG_PLUGINS_BY_DEFAULT=0"
            "-DBUILD_OSG_DEPRECATED_SERIALIZERS=0"
        ] ++ (map (e: "-DBUILD_OSG_PLUGIN_${e}=1") [ "BMP" "DAE" "DDS" "FREETYPE" "JPEG" "OSG" "PNG" "TGA" ]);
    });

    bullet' = bullet.overrideDerivation (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
            "-Wno-dev"
            "-DOpenGL_GL_PREFERENCE=${GL}"
            "-DUSE_DOUBLE_PRECISION=ON"
            "-DBULLET2_MULTITHREADING=ON"
        ];
    });

    mygui' = inputs.mygui.legacyPackages.x86_64-linux.mygui.overrideDerivation (old: {
        cmakeFlags = (old.cmakeFlags or []) ++ [
            "-DMYGUI_DONT_USE_OBSOLETE=ON"
        ];
    });

in
stdenv.mkDerivation {
    pname = "openmw";
    version = "0.49.0";

    src = fetchFromGitLab {
        owner = "OpenMW";
        repo = "openmw";
        rev = "cbf0471d8a54e4f8fd1093e698c839f11997693a";
        hash = "sha256-EVn61FFLHNPfzMgrr1Cykoco2Kmdd1OI2pysY+2iClA=";
    };

    postPatch = ''
        sed '1i#include <memory>' -i components/myguiplatform/myguidatamanager.cpp # gcc12
    '';

    nativeBuildInputs = [ cmake pkg-config wrapQtAppsHook ];

    buildInputs = [
        SDL2
        boost
        bullet'
        ffmpeg
        luajit
        lz4
        mygui'
        openal
        osg'
        qt6.full
        qt6.qtbase
        recastnavigation
        unshield
        xorg.libXt
        yaml-cpp
    ];

    cmakeFlags = [
        "-DOpenGL_GL_PREFERENCE=${GL}"
        "-DOPENMW_USE_SYSTEM_RECASTNAVIGATION=1"
    ];
}
