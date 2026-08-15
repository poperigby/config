{ lib, ... }:

{
    pkgs,
    package ? null,
    source ? null,
    desktopFile ? null,
    outputFile ? null,
    replace ? { },
}:
let
    inherit (lib)
        attrNames
        concatMapStringsSep
        removeSuffix
        ;

    resolvedSource =
        if source != null then
            source
        else if package != null && desktopFile != null then
            "${package}/share/applications/${desktopFile}"
        else
            throw "modify-desktop-entry requires source or both package and desktopFile";

    resolvedOutputFile =
        if outputFile != null then
            outputFile
        else if desktopFile != null then
            desktopFile
        else
            throw "modify-desktop-entry requires outputFile when desktopFile is unset";

    editArgs = concatMapStringsSep " " (
        key:
        concatMapStringsSep " " lib.escapeShellArg [
            "--set-key=${key}"
            "--set-value=${replace.${key}}"
        ]
    ) (attrNames replace);
in
pkgs.runCommand (removeSuffix ".desktop" resolvedOutputFile)
    { nativeBuildInputs = [ pkgs.desktop-file-utils ]; }
    ''
        entry="$out/share/applications/${resolvedOutputFile}"

        install -Dm644 ${lib.escapeShellArg resolvedSource} "$entry"

        ${lib.optionalString (replace != { }) ''
            desktop-file-edit ${editArgs} \
                --remove-key=X-Desktop-File-Install-Version \
                "$entry"
        ''}

        if ! validation_output="$(desktop-file-validate "$entry" 2>&1)"; then
            printf '%s\n' "$validation_output"
            exit 1
        fi
    ''
