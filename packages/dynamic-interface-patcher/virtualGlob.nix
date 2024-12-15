{
    buildPythonPackage,
    fetchPypi,
    flit-core,
    lib,
    pytest,
}:

buildPythonPackage rec {
    pname = "virtual-glob";
    version = "0.2.0";
    pyproject = true;

    src = fetchPypi {
        pname = "virtual_glob";
        inherit version;
        hash = "sha256-FoHK4giC3pWRxmO4LRVgGduWy1PBgMZkhTyhWpcHvdI=";
    };

    build-system = [
        flit-core
    ];

    optional-dependencies = {
        testing = [
            pytest
        ];
    };

    pythonImportsCheck = [
        "virtual_glob"
    ];

    meta = {
        description = "Globbing of virtual file systems";
        homepage = "https://pypi.org/project/virtual_glob/";
        license = lib.licenses.mit;
    };
}
