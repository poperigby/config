{
    cmake,
    fetchFromGitHub,
    kdePackages,
    lib,
    libx11,
    libxcb,
    libxcb-image,
    libxcb-util,
    libxcb-wm,
    libxcomposite,
    libxdamage,
    libxfixes,
    libxtst,
    pkg-config,
    qt6,
    stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
    pname = "xembed-sni-proxy";
    version = "unstable-2025-06-21";

    src = fetchFromGitHub {
        owner = "BLumia";
        repo = "xembed-sni-proxy";
        rev = "c3afbd4c1d26a19622cd7c2cae3db3d35fdd0d33";
        hash = "sha256-cxEOrPUPtNTFSgH8hsbft/1dmPsXhONQgFnOWuzFfTk=";
    };

    postPatch = ''
                substituteInPlace CMakeLists.txt \
                    --replace-fail 'include(KDEInstallDirs)' 'include(KDEInstallDirs)
        include(FeatureSummary)'
    '';

    nativeBuildInputs = [
        cmake
        kdePackages.extra-cmake-modules
        pkg-config
        qt6.wrapQtAppsHook
    ];

    buildInputs = [
        kdePackages.kwindowsystem
        libx11
        libxcb
        libxcb-image
        libxcb-util
        libxcb-wm
        libxcomposite
        libxdamage
        libxfixes
        libxtst
        qt6.qtbase
    ];

    meta = {
        description = "Standalone xembed system tray to StatusNotifierItem proxy";
        homepage = "https://github.com/BLumia/xembed-sni-proxy";
        license = lib.licenses.lgpl21Plus;
        maintainers = with lib.maintainers; [ PopeRigby ];
        mainProgram = "xembedsniproxy";
        platforms = lib.platforms.linux;
    };
})
