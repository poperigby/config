{ den, ... }:
{
    den.aspects.programs.provides.jujutsu.homeManager =
        {
            config,
            pkgs,
            privateInfo,
            ...
        }:
        let
            getExe = pkgs.lib.getExe;
            mkAlias = name: script: [
                "util"
                "exec"
                "--"
                (getExe (pkgs.writeShellScriptBin name script))
            ];
        in
        {
            programs.jujutsu = {
                enable = true;
                settings = {
                    user = {
                        name = privateInfo.poperigby.name;
                        email = privateInfo.poperigby.email;
                    };
                    ui = {
                        default-command = [ "status" ];
                        pager = "delta";
                        diff-editor = [
                            (getExe config.programs.neovim.finalPackage)
                            "-c"
                            "DiffEditor $left $right $output"
                        ];
                    };
                    templates.log = "builtin_log_compact";
                    merge-tools.difft = {
                        program = "difft";
                        diff-args = [
                            "--color=always"
                            "$left"
                            "$right"
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

            home.packages = with pkgs; [
                lazyjj
                jjui
            ];
        };
}
