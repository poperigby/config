# Downloads the parts of The Witcher 3 REDkit that its wcc_lite.exe needs and
# patches out its EULA dialog, so WolvenKit can use it to uncook next-gen
# bundles. The full REDkit install is around 110 GB; this fetches about 1.5 GB.
{
    coreutils,
    depotdownloader,
    gnugrep,
    writeShellApplication,
}:

writeShellApplication {
    name = "wolvenkit-fetch-wcc";
    runtimeInputs = [
        coreutils
        depotdownloader
        gnugrep
    ];
    text = ''
        if (($# < 1 || $# > 2)); then
            echo "usage: wolvenkit-fetch-wcc STEAM_USER [DIR]" >&2
            exit 1
        fi
        user=$1
        dir=''${2:-''${XDG_DATA_HOME:-$HOME/.local/share}/wolvenkit7/redkit}
        mkdir -p "$dir"

        filelist=$(mktemp)
        trap 'rm -f "$filelist"' EXIT
        # bin/ holds wcc_lite and the DLLs it loads; bin/tools is cooker test
        # scripts. wcc_lite boots the engine against ../../r4data, which needs
        # these files from the 108 GB depot to get far enough to uncook.
        cat >"$filelist" <<'EOF'
        regex:^bin/(?!tools/)
        regex:^r4data/(dep\.cache|staticshader[^/]*\.cache)$
        regex:^r4data/game/
        regex:^r4data/gameplay/globals/
        r4data/soundbanks/Pc/Init.bnk
        EOF

        # -validate restores wcc_lite.exe to the depot's copy before it is
        # patched again, so an updated depot never gets diffed against the patch.
        for depot in 2684662 2684661; do
            DepotDownloader -app 2684660 -depot "$depot" -os windows \
                -username "$user" -remember-password -validate \
                -filelist "$filelist" -dir "$dir"
        done

        # wcc_lite reads its EULA acceptance with a buffer size taken from an
        # unrelated variable, so the registry value is often ignored and the
        # dialog blocks every call. The patch turns the jne after
        # `cmp byte [rbp+0x4f0], 0` (the -agreetoterms flag) into a jmp past the
        # dialog.
        exe="$dir/bin/x64_RedKit/wcc_lite.exe"
        check='\x80\xbd\xf0\x04\x00\x00\x00'
        if LC_ALL=C grep -qUaP "''${check}\x90\xe9" "$exe"; then
            echo "wolvenkit-fetch-wcc: $exe is already patched"
            exit 0
        fi
        mapfile -t offsets < <(LC_ALL=C grep -obUaP "''${check}\x0f\x85" "$exe" | cut -d: -f1)
        if ((''${#offsets[@]} != 1)); then
            echo "wolvenkit-fetch-wcc: found ''${#offsets[@]} EULA checks in $exe, expected 1" >&2
            exit 1
        fi
        printf '\x90\xe9' | dd of="$exe" bs=1 seek=$((offsets[0] + 7)) conv=notrunc status=none
        echo "wolvenkit-fetch-wcc: patched $exe"
    '';
}
