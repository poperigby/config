{
    fetchFromGitHub,
    installShellFiles,
    lib,
    makeWrapper,
    networkmanager,
    rofi-unwrapped,
    stdenv,
    zsh,
}:

stdenv.mkDerivation rec {
    pname = "rofi-wifi";
    version = "unstable-2024-03-17";

    src = fetchFromGitHub {
        owner = "ZigaSajovic";
        repo = "rofi-wifi-menu-plus-plus";
        rev = "3fbc769865803f86e668151ac29eadf3dfe3ac2c";
        hash = "sha256-WTfD3VYuZ07y6/sc/w3IEJ6V/4ew4pVk7T4xbau7bNY=";
    };

    buildInputs = [ zsh ];

    nativeBuildInputs = [
        installShellFiles
        makeWrapper
    ];

    installPhase = ''
        runHook preInstall

        mv rofi_wifi_menu ${pname}
        installBin ${pname}

        wrapProgram $out/bin/${pname} \
            --prefix PATH ":" ${lib.makeBinPath [ rofi-unwrapped networkmanager ]}

        runHook postInstall
    '';

    meta = {
        description = "An enhanced rofi menu for managing WiFi connections";
        homepage = "https://github.com/ZigaSajovic/rofi-wifi-menu-plus-plus";
        mainProgram = pname;
    };
}
