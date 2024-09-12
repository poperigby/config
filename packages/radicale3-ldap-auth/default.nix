{
    fetchFromGitHub,
    lib,
    python3Packages,
    radicale,
    ...
}:

python3Packages.buildPythonPackage rec {
    pname = "radicale3-ldap-auth";
    version = "unstable-2024-08-17";
    format = "setuptools";

    src = fetchFromGitHub {
        owner = "malmeloo";
        repo = pname;
        rev = "249842085cf6f7fa7bcee655033f6b5ca15b36e8";
        hash = "sha256-TNgK96OvPMooX5Jcr+FFI+jHibD6f9jFvTpFbkVdQDM=";
    };

    propagatedBuildInputs = [ radicale ];
    pythonImportsCheck = [ "radicale" ];

    meta = {
        description = "LDAP authentication plugin for Radicale 3 DAV server";
        homepage = "https://github.com/malmeloo/radicale3-ldap-auth";
        license = lib.licenses.gpl3;
        maintainers = with lib.maintainers; [ PopeRigby ];
    };
}
