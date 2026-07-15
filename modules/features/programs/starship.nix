{ ... }:
{
    flake-file.inputs.jj-starship.url = "github:dmmulroy/jj-starship";

    den.aspects.programs.provides.starship.homeManager =
        {
            lib,
            inputs',
            ...
        }:
        let
            inherit (lib) concatStrings getExe;
            jj-starship = inputs'.jj-starship.packages.jj-starship;
        in
        {
            programs.starship = {
                enable = true;
                settings = {
                    add_newline = false;
                    format = concatStrings [
                        "$directory"
                        "$shlvl"
                        "$git_branch"
                        "$git_commit"
                        "$git_state"
                        "$git_status"
                        "\${custom.jj}"
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
                    git_branch = {
                        format = "[$branch(:$remote_branch)]($style) ";
                        style = "green";
                    };
                    git_status = {
                        format = "([$all_status$ahead_behind]($style) )";
                        ahead = "⇡\${count}";
                        behind = "⇣\${count}";
                        diverged = "⇡\${ahead_count}⇣\${behind_count}";
                        modified = "!\${count}";
                        deleted = " ";
                        stashed = "*";
                        style = "bold yellow";
                    };
                    custom.jj = {
                        when = "${getExe jj-starship} detect";
                        format = "$output ";
                        shell = [ (getExe jj-starship) ];
                    };
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
