{
    lib,
    buildGoModule,
    fetchgit,
    ffmpeg,
    flutter,
    libreoffice,
    makeFontsConf,
    makeWrapper,
    noto-fonts,
    pkg-config,
    poppler-utils,
    vips,
}:

let
    version = "0.9.1";

    src = fetchgit {
        url = "https://codeberg.org/shroff/phylum.git";
        rev = "refs/tags/releases/v${version}";
        hash = "sha256-6HKMEp2jnIpnp40jTwvM9GGt1cjQOqufTDJeqLfzor4=";
    };

    web = flutter.buildFlutterApplication {
        pname = "phylum-web";
        inherit version src;

        sourceRoot = "${src.name}/client";
        pubspecLock = lib.importJSON ./pubspec.lock.json;
        gitHashes = {
            flutter_typeahead = "sha256-U+363irTeQCt1eBUWI5ac/8rzWA4hRI1Rk6vwWAENLM=";
            offtheline = "sha256-wuQu/YjUPdWD5qyVQRk4BnU2cs+1Jp2QDIE4RToBbzw=";
        };
        # These deprecated compatibility packages no longer ship Linux build
        # files. They are unused by the web target, so retain their Dart source
        # without applying nixpkgs' native-Linux source builders.
        customSourceBuilders = {
            sqlcipher_flutter_libs = { src, ... }: src;
            sqlite3_flutter_libs = { src, ... }: src;
        };
        targetFlutterPlatform = "web";
        flutterBuildFlags = [ "--wasm" ];
    };
in
buildGoModule {
    pname = "phylum";
    inherit version src;

    sourceRoot = "${src.name}/server";
    patches = [ ./postgresql-unaccent-wrapper.patch ];
    vendorHash = "sha256-h5z5AhvFazMNXSYHYI6JkgoEP5yKIi/vUacdCqgdtdw=";

    nativeBuildInputs = [
        makeWrapper
        pkg-config
    ];
    buildInputs = [
        ffmpeg
        vips
    ];

    subPackages = [ "cmd" ];

    postInstall = ''
        mv "$out/bin/cmd" "$out/bin/phylum"
        mkdir -p "$out/share/phylum"
        cp -r ${web} "$out/share/phylum/web"
    '';

    postFixup = ''
        wrapProgram "$out/bin/phylum" \
            --prefix PATH : ${
                lib.makeBinPath [
                    libreoffice
                    poppler-utils
                    vips
                ]
            } \
            --set FONTCONFIG_FILE ${makeFontsConf { fontDirectories = [ noto-fonts ]; }}
    '';

    meta = {
        description = "Self-hosted file storage and sharing server";
        homepage = "https://codeberg.org/shroff/phylum";
        license = lib.licenses.agpl3Only;
        mainProgram = "phylum";
        platforms = lib.platforms.linux;
    };
}
