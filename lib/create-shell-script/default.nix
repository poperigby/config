{ lib }:

let
    inherit (lib) makeBinPath;
in
{
    createShellScript =
        {
            pkgs,
            pname,
            src,
            version ? "1.0",
            deps,
        }:
        pkgs.stdenv.mkDerivation {
            inherit pname src version;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            phases = [ "installPhase" ];

            installPhase = ''
                mkdir -p $out/bin
                install -m +x $src $out/bin/${pname}

                wrapProgram $out/bin/${pname} \
                  --prefix PATH : ${makeBinPath deps}
            '';

            meta.mainProgram = pname;
        };
}
