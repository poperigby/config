{ ... }:

final: prev: {
    radicale = prev.radicale.overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "Kozea";
            repo = "Radicale";
            rev = "7fbc0e70e92fa20e0de573096732d217184a7ca2";
            hash = "sha256-UURSfywjJ1zRU6v7YGnjKviadXjalq3ZwrjcoZ7GPqQ=";
        };

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
            prev.python3.pkgs.ldap3
        ];
    });
}
