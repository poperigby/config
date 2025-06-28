TMP="/tmp/cliphist"
rm -rf "$TMP"

if [[ -n "$1" ]]; then
    cliphist decode <<<"$1" | wl-copy
    exit
fi

mkdir -p "$TMP"

read -r -d \'\' prog <<EOF
/^[0-9]+\s<meta http-equiv=/ { next }
match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
    system("echo " grp[1] "\\\\\t | cliphist decode >$TMP/"grp[1]"."grp[3])
    print \$0"\0icon\x1f$TMP/"grp[1]"."grp[3]
    next
}
1
EOF
cliphist list | gawk "$prog"
