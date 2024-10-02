{ ... }:

final: prev: {
    lynis = prev.lynis.overrideAttrs(old: rec {
        version = "3.1.2";
        src = prev.fetchFromGitHub {
            owner = "CISOfy";
            repo = old.pname;
            rev = version;
            sha256 = "sha256-K3+E3ODXti88wGE3trxZYTKPe7tYfPI85C/5jXea2uw=";
        };
    });
}
