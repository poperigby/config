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

    # Helper to define aliases
    mkAlias = name: script: [
        "util"
        "exec"
        "--"
        (getExe (pkgs.writeShellScriptBin name script))
    ];
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
                    tug = mkAlias "tug" ''
                        if [ "x$1" = "x" ]; then
                            jj bookmark move --from "closest_bookmark(@)" --to "closest_pushable(@)"
                        else
                            jj bookmark move --to "closest_pushable(@)" "$@"
                        fi
                    '';

                    push = mkAlias "push" ''
                        jj tug && jj git push
                    '';

                    pull = mkAlias "pull" ''
                        jj git fetch && jj new -r "trunk()"
                    '';
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
