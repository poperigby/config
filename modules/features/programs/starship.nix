{ ... }:
{
    den.aspects.programs.provides.starship.homeManager =
        { lib, ... }:
        let
            inherit (lib) concatStrings;
        in
        {
            programs.starship = {
                enable = true;
                settings = {
                    add_newline = false;
                    format = concatStrings [
                        "$directory"
                        "$shlvl"
                        "$vcs"
                        "$jobs"
                        "$status"
                        "$container"
                        "$nix_shell"
                        "$shell"
                        "$character"
                    ];
                    right_format = concatStrings [
                        "$hostname"
                    ];
                    character = {
                        success_symbol = "[❯](green)";
                        error_symbol = "[❯](red)";
                    };
                    directory = {
                        format = "[$path]($style) [$read_only]($read_only_style)";
                        read_only = " ";
                        fish_style_pwd_dir_length = 3;
                        truncation_length = 3;
                    };
                    vcs = {
                        order = [
                            "jj"
                            "git"
                        ];
                        jj_modules = "$jj_change$jj_bookmark$jj_status";
                    };
                    jj_change.format = "[󱗆 ](blue)$change ";
                    jj_bookmark.format = "[$bookmark(@$remote)$diverged]($style) ";
                    jj_status.style = "bold yellow";
                    nix_shell = {
                        format = "[$symbol]($style)";
                        symbol = "󱄅 ";
                        heuristic = true;
                    };
                    shell = {
                        bash_indicator = "#";
                        fish_indicator = "";
                        nu_indicator = "";
                        format = "[$indicator]($style)";
                        style = "bold purple";
                        disabled = false;
                    };
                    hostname = {
                        format = "[$hostname $ssh_symbol]($style)";
                        ssh_symbol = " ";
                        style = "yellow";
                    };
                };
            };
        };
}
