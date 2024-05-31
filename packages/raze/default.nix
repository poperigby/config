{
  lib
, stdenv
, fetchFromGitHub
, makeWrapper
, makeDesktopItem , copyDesktopItems
, SDL2
, bzip2
, cmake
, fluidsynth
, game-music-emu
, gtk3
, imagemagick
, libGL
, libjpeg
, libsndfile
, libvpx
, libwebp
, mpg123
, ninja
, openal
, pkg-config
, vulkan-loader
, zlib
, zmusic
}:

stdenv.mkDerivation rec {
  pname = "raze";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "ZDoom";
    repo = "Raze";
    rev = "g${version}";
    fetchSubmodules = true;
    hash = lib.fakeHash;
  };

  outputs = [ "out" "doc" ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    imagemagick
    makeWrapper
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    bzip2
    fluidsynth
    game-music-emu
    gtk3
    libGL
    libjpeg
    libsndfile
    libvpx
    libwebp
    mpg123
    openal
    vulkan-loader
    zlib
    zmusic
  ];

  postPatch = ''
    substituteInPlace tools/updaterevision/UpdateRevision.cmake \
      --replace "ret_var(Tag)" "ret_var(\"${src.rev}\")" \
      --replace "ret_var(Timestamp)" "ret_var(\"1970-00-00 00:00:00 +0000\")" \
      --replace "ret_var(Hash)" "ret_var(\"${src.rev}\")"
  '';

  cmakeFlags = [
    "-DDYN_GTK=OFF"
    "-DDYN_OPENAL=OFF"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "raze";
      exec = "raze";
      desktopName = "Raze";
      comment = meta.description;
      icon = "raze";
      categories = [ "Game" ];
    })
  ];

  postInstall = ''
    mv $out/bin/raze $out/share/games/doom/raze
    makeWrapper $out/share/games/doom/rase $out/bin/raze

    for size in 16 24 32 48 64 128; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -background none -resize "$size"x"$size" $src/src/win32/icon1.ico -flatten \
        $out/share/icons/hicolor/"$size"x"$size"/apps/raze.png
    done;
  '';

  meta = with lib; {
    homepage = "https://github.com/ZDoom/Raze";
    description = "Build engine port backed by GZDoom tech";
    mainProgram = "raze";
    longDescription = ''
      Build engine port backed by GZDoom tech. Currently supports Duke Nukem 3D, Blood,
      Shadow Warrior, Redneck Rampage and Powerslave/Exhumed. 
    '';
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ azahi lassulus ];
  };
}
