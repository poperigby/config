{ ... }:

final: prev: {
    radicale = prev.radicale.overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "Kozea";
            repo = "Radicale";
            rev = "da844f48e6809d7d93e6ffef30d9051be00b74b5";
            hash = "sha256-3nXuR7Xs3Cb7DDNmQ3AcxDeOy0pl0Se92889z2mtguU=";
        };

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
            prev.python3.pkgs.ldap3
        ];
    });
}
