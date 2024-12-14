{ ... }:

final: prev: {
    radicale = prev.radicale.overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "Kozea";
            repo = "Radicale";
            rev = "4d04c85f2ddb7d1448787ba0328ed25cc9595123";
            hash = "sha256-OQhc/9PxaT+g/w+xVkEYdUmf7q1ZGUt2z06B8Oc/9Ys=";
        };

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
            prev.python3.pkgs.ldap3
        ];
    });
}
