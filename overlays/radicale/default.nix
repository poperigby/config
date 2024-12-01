{ ... }:

final: prev: {
    radicale = prev.radicale.overrideAttrs(old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [
            prev.python3.pkgs.ldap3
        ];
    });
}
