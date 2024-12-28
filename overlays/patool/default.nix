{ ... }:

final: prev: {
  python312 = prev.python312.override {
    packageOverrides = python-final: python-prev: {
      patool = python-prev.patool.overridePythonAttrs (old: {
        doCheck = false;
      });
    };
  };
}
