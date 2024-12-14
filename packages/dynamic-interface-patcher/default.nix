{
    fetchFromGitHub,
    inputs,
    lib,
    python3,
    system,
}:

python3.pkgs.buildPythonApplication {
    pname = "dynamic-interface-patcher";
    version = "unstable-2024-11-20";
    pyproject = true;

    src = fetchFromGitHub {
        owner = "Cutleast";
        repo = "Dynamic-Interface-Patcher";
        rev = "1be782d15b9f149b73d5ec3a2f82d87ac3bb7eca";
        hash = "sha256-3FVYMwG9kJ2HFisjw7cY+1OFOMZQvbjqIFeaPSpD3Ks=";
    };

    build-system = with python3.pkgs; [
        setuptools
        wheel
    ];

    dependencies = (with python3.pkgs; [
        lz4
        pyperclip
        pyside6
        qtawesome
        qtpy
        rarfile
        virtual-glob
        jstyleson
    ]) ++ [
        inputs.p7zr.legacyPackages.${system}.python3.pkgs.p7zr
    ];

    pythonImportsCheck = [ "dynamic_interface_patcher" ];

    meta = {
        description = "A dynamic patching tool for Skyrim ui mods with strict permissions like RaceMenu or MiniMap";
        homepage = "https://github.com/Cutleast/Dynamic-Interface-Patcher";
        license = lib.licenses.cc-by-nc-nd-40;
        mainProgram = "dynamic-interface-patcher";
    };
}
