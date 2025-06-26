{ inputs, ... }:

final: prev: {
  python313 = prev.python313.override {
    packageOverrides = python-final: python-prev: {
      lxml-html-clean =
        inputs.lxml-html-clean.legacyPackages.${prev.system}.python313Packages.lxml-html-clean;
    };
  };
}
