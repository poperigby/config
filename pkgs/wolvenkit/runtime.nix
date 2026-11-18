# Wine prefix with .NET Framework 4.8, built by mkWindowsApp as cached layers
# under ~/.cache/mkWindowsApp. This derivation does not depend on the WolvenKit
# release, so updating WolvenKit reuses the existing .NET layer.
#
# The launcher reads its inputs from the environment:
#   WOLVENKIT_APP     writable directory holding WolvenKit's files
#   WOLVENKIT_EXE     executable to run, relative to WOLVENKIT_APP
#   WOLVENKIT_ARGS    arguments, serialized with `printf '%q '`
#   WOLVENKIT_STATUS  file that receives the executable's exit status
# It writes the executable's stdout to file descriptor 3.
{
    inputs,
    wine,
}:

inputs.erosanix.lib.x86_64-linux.mkWindowsAppNoCC {
    pname = "wolvenkit-runtime";
    inherit (wine) version;
    inherit wine;

    wineArch = "win64";
    enableMonoBootPrompt = false;

    dontUnpack = true;

    winAppInstall = ''
        export WINE WINEDEBUG=-all
        # WolvenKit targets net481, but Microsoft ships 4.8.1 for Windows 10 as a
        # servicing package that Wine cannot install. The 4.8 runtime runs it.
        # dotnet48 leaves the prefix on Windows 7, so win10 restores it.
        winetricks -q dotnet48 win10
    '';

    winAppRun = ''
        export WINEDEBUG=-all
        args=()
        eval "args=($WOLVENKIT_ARGS)"
        # Absolute Linux paths whose file or parent directory exists become Windows paths.
        for i in "''${!args[@]}"; do
            if [[ "''${args[i]}" == /* && -e "$(dirname -- "''${args[i]}")" ]]; then
                args[i]=$("$WINE" winepath -w "''${args[i]}" 2>/dev/null)
            fi
        done
        cd "$WOLVENKIT_APP"
        "$WINE" "$WOLVENKIT_APP/$WOLVENKIT_EXE" "''${args[@]}" >&3
        echo "$?" > "$WOLVENKIT_STATUS"
    '';

    installPhase = ''
        runHook preInstall
        runHook postInstall
    '';
}
