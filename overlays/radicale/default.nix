{ ... }:

final: prev: {
    radicale = prev.radicale.overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "PopeRigby";
            repo = "Radicale";
            rev = "cd0822c7029d";
            hash = "sha256-hEg49Mr0Q8yFjKIv8hGiUjbccHqN4O8QO+n/rdS5F6k=";
        };

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
            prev.python3.pkgs.ldap3
        ];
    });
}
