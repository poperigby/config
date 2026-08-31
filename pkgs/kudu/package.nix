{
    e2fsprogs,
    fetchFromGitHub,
    lib,
    makeWrapper,
    nix-update-script,
    passt,
    pkg-config,
    qemu,
    rustPlatform,
    tigervnc,
    xorriso,
}:

rustPlatform.buildRustPackage (finalAttrs: {
    pname = "kudu";
    version = "0.2.1";

    __structuredAttrs = true;

    src = fetchFromGitHub {
        owner = "pythops";
        repo = "kudu";
        tag = "v${finalAttrs.version}";
        hash = "sha256-KVS8k8Chs5DVChSvaJcjtSO92BOM9XKh0LjMmZm0fik=";
    };

    cargoHash = "sha256-OnLZH2ZhBKFl3tOnH7i6eIP2z0UZ9CtV/Tu6E3qsFGs=";

    nativeBuildInputs = [
        pkg-config
        makeWrapper
    ];

    postInstall = ''
        wrapProgram $out/bin/${finalAttrs.pname} \
            --prefix PATH : ${
                lib.makeBinPath [
                    e2fsprogs
                    passt
                    qemu
                    tigervnc
                    xorriso
                ]
            }
    '';

    passthru.updateScript = nix-update-script { };

    meta = {
        description = "TUI VM Manager on Linux";
        homepage = "https://github.com/pythops/kudu";
        changelog = "https://github.com/pythops/kudu/releases/tag/${finalAttrs.src.tag}";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ PopeRigby ];
        mainProgram = "kudu";
    };
})
