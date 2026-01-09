{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.programs.jujutsu;
in
{
    options.custom.programs.jujutsu.enable = mkEnableOption "jujutsu";

    config = mkIf cfg.enable {
        programs.jujutsu = {
            enable = true;
            settings = {
                user = {
                    name = config.privateInfo.poperigby.name;
                    email = config.privateInfo.poperigby.email;
                };
                ui = {
                    default-command = [ "status" ];
                    diff-editor = [
                        (getExe config.programs.neovim.finalPackage)
                        "-c"
                        "DiffEditor $left $right $output"
                    ];
                };
                aliases = {
                    tug = [
                        "util"
                        "exec"
                        "--"
                        (getExe (
                            pkgs.writeShellScriptBin "tug" ''
                                if [ "x$1" = "x" ]; then
                                  jj bookmark move --from "closest_bookmark(@)" --to "closest_pushable(@)"
                                else
                                  jj bookmark move --to "closest_pushable(@)" "$@"
                                fi
                            ''
                        ))
                    ];
                    push = [
                        "util"
                        "exec"
                        "--"
                        (getExe (
                            pkgs.writeShellScriptBin "push" ''
                                jj tug && jj git push
                            ''
                        ))
                    ];
                };
                revset-aliases = {
                    "closest_bookmark(to)" = "heads(::to & bookmarks())";
                    "closest_pushable(to)" = ''
                        heads(::to & mutable() & ~description(exact:" ") & (~empty() | merges()))
                    '';
                };
            };
        };
    };
}
