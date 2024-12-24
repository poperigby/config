{
  boost,
  cmake,
  fetchFromGitHub,
  fmt_11,
  git,
  gtest,
  icu,
  installShellFiles,
  lib,
  libloot,
  minizip-ng,
  ogdf,
  custom,
  qt6Packages,
  spdlog,
  stdenv,
  tbb_2021_11,
  tomlplusplus,
  ...
}:

stdenv.mkDerivation rec {
  pname = "loot";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "loot";
    repo = "loot";
    rev = version;
    hash = "sha256-PFgL3VCi95SvhNEF/Ffqoo4uBUF9ID/7TVf/54vNREI=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    cmake
    git
    installShellFiles
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    (boost.override { enableStatic = true; })
    fmt_11
    icu
    libloot
    minizip-ng
    ogdf
    custom.valve-file-vdf
    qt6Packages.qtbase
    qt6Packages.qtwayland
    spdlog
    tbb_2021_11
    tomlplusplus
  ];

  cmakeFlags =
    let
      inherit (lib) cmakeFeature cmakeBool;
    in
    [
      (cmakeFeature "FETCHCONTENT_SOURCE_DIR_FMT" "${fmt_11.src}")
      (cmakeFeature "FETCHCONTENT_SOURCE_DIR_GTEST" "${gtest.src}")
      (cmakeFeature "FETCHCONTENT_SOURCE_DIR_MINIZIP" "${minizip-ng.src}")
      (cmakeFeature "FETCHCONTENT_SOURCE_DIR_SPDLOG" "${spdlog.src}")
      (cmakeFeature "FETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS" "${tomlplusplus.src}")
      (cmakeFeature "FETCHCONTENT_SOURCE_DIR_VALVEFILEVDF" "${custom.valve-file-vdf.src}")
      (cmakeBool "LOOT_BUILD_TESTS" false)
    ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    installBin LOOT

    mkdir -p $out/share/metainfo
    install -D ../resources/linux/io.github.loot.loot.metainfo.xml $out/share/metainfo/io.github.loot.loot.metainfo.xml

    mkdir -p $out/share/applications
    install -D ../resources/linux/io.github.loot.loot.desktop $out/share/applications/io.github.loot.loot.desktop

    mkdir -p $out/share/icons/hicolor/scalable/apps
    install -D ../resources/icons/loot.svg $out/share/icons/hicolor/scalable/apps/io.github.loot.loot.svg

    runHook postInstall
  '';

  meta = {
    description = "A modding utility for Starfield and some Elder Scrolls and Fallout games";
    homepage = "https://github.com/loot/loot";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    mainProgram = "LOOT";
  };
}
