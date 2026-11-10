# Lists man pages like `apropos .`, including pages from Nix store paths in
# MANPATH (e.g. inside a dev shell). Each store path gets its own man-db index
# under the cache directory, built once since store paths are immutable. Each
# index is touched on use so age-based cleanup only removes unused ones.
# man-db is called via $man_db rather than PATH, since manpath derives search
# directories from PATH.

cache="${XDG_CACHE_HOME:-$HOME/.cache}/tv-man"
mkdir -p "$cache"
cfg="$(mktemp)"
trap 'rm -f "$cfg"' EXIT
cat /etc/man_db.conf >"$cfg"

mapfile -t dirs < <("$man_db/manpath" 2>/dev/null | tr : '\n' | grep '^/nix/store/' || true)
for d in "${dirs[@]}"; do
    db="$cache/$(basename "$(dirname "$(dirname "$d")")")"
    echo "MANDB_MAP $d $db" >>"$cfg"
    if [ -e "$db/index.db" ]; then
        touch "$db/index.db"
    else
        "$man_db/mandb" -q -C "$cfg" "$d" >/dev/null 2>&1 || true
    fi
done

"$man_db/apropos" -l -C "$cfg" . 2>/dev/null || true
