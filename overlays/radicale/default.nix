{ ... }:

final: prev: {
    radicale = prev.radicale.overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "PopeRigby";
            repo = "Radicale";
            rev = "94562b0b5d55019c513e638c664c8c1fd4bc067e";
            hash = "sha256-t/bZNh4cvJRYmM/DEswsvw7My+L54XMnw9R1CISHdXQ=";
        };

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
            prev.python3.pkgs.ldap3
        ];
    });
}
