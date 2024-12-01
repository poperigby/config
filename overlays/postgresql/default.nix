{ ... }:

final: prev: {
    postgresql = prev.postgresql.overrideAttrs(old: {
        patches = old.patches ++ [
            (prev.fetchurl {
              url = "https://www.postgresql.org/message-id/attachment/122092/0002-earthdistance-sql-functions.patch";
              hash = "sha256-BOaGC0QSArwigsff9H8GPe6oOmDdjOfojsdO8sBQqkc=";
            })
        ];
    });
}
