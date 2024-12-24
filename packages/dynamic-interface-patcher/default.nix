{
  fetchFromGitHub,
  inputs,
  lib,
  python3,
  system,
}:

python3.pkgs.buildPythonApplication {
  pname = "dynamic-interface-patcher";
  version = "unstable-2024-12-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "poperigby";
    repo = "Dynamic-Interface-Patcher";
    rev = "baf83cc9af207894b178488200818459ff674201";
    hash = "sha256-TdZghwPHd8ijE1+6AE10jlTyGIdEJ3UjTkn0duDGUSw=";
  };

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  dependencies =
    (with python3.pkgs; [
      jstyleson
      lz4
      pyperclip
      pyside6
      qtawesome
      qtpy
      rarfile
    ])
    ++ [
      inputs.chime.legacyPackages.${system}.python3.pkgs.chime
      inputs.py7zr.legacyPackages.${system}.python3.pkgs.py7zr
      inputs.virtual-glob.legacyPackages.${system}.python3.pkgs.virtual-glob
    ];

  meta = {
    description = "A dynamic patching tool for Skyrim UI mods with strict permissions like RaceMenu or MiniMap";
    homepage = "https://github.com/poperigby/Dynamic-Interface-Patcher";
    license = lib.licenses.cc-by-nc-nd-40;
    mainProgram = "dip";
  };
}
