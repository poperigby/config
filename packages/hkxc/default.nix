{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "hkxc";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "SARDONYX-sard";
    repo = "serde-hkx";
    tag = version;
    hash = "sha256-xSlaw1uKglTOYcpnMWw4Vq7oR7i8/qd50QNauVuvRSQ=";
  };

  cargoHash = "sha256-ZKnYZLSRekN5fmbR9ROvdTjkx/H/9KIhlIGhRk61z0s=";

  meta = {
    description = "Pure Rust cross-platform Havok behavior (De)Serialization library.(ver. hk_2010.2.0-r1";
    homepage = "https://github.com/SARDONYX-sard/serde-hkx";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "hkxc";
  };
}
