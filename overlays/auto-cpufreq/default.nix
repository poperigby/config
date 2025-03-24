{ ... }:

final: prev: {
  # https://github.com/NixOS/nixpkgs/issues/392278
  auto-cpufreq = prev.auto-cpufreq.overrideAttrs (oldAttrs: {
    postPatch =
      oldAttrs.postPatch
      + ''
        substituteInPlace pyproject.toml \
        --replace-fail 'psutil = "^6.0.0"' 'psutil = ">=6.0.0,<8.0.0"'
      '';
  });
}
