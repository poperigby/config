{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        concatStrings
        getExe
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.programs.starship;
    tomlFormat = pkgs.formats.toml { };
in
{
    options.custom.programs.starship.enable = mkEnableOption "Enable Starship prompt";

    config = mkIf cfg.enable {
        programs.starship = {
            enable = true;
            settings = {
                ## Top level configuration
                # Don't print a new line at the start of the prompt
                add_newline = false;
                # Left prompt
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
                # Right prompt
                right_format = concatStrings [
                    "$hostname"
                ];

                ## Module configuration
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
                    # Component formatting
                    ahead = "⇡\${count}";
                    behind = "⇣\${count}";
                    diverged = "⇡\${ahead_count}⇣\${behind_count}";
                    modified = "!\${count}";
                    deleted = " ";
                    stashed = "*";
                    style = "bold yellow";
                };
                custom.jj = {
                    command = "prompt";
                    format = "$output";
                    ignore_timeout = true;
                    shell = [
                        (getExe pkgs.custom.starship-jj)
                        "--ignore-working-copy"
                        "starship"
                    ];
                    use_stdin = false;
                    when = true;

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

        xdg.configFile."starship-jj/starship-jj.toml".source = tomlFormat.generate "starship-jj.toml" {
            "$schema" = "https://gitlab.com/Lanastara/lanastara_foss/-/raw/v0.3.0/schema.json?ref_type=tags";

            # Text that will be printed between each Module.
            module_separator = " ";

            # Controls whether colors are reset at the end of output.
            # Try this if your prompt displays a blank space at the end.
            # reset_color = true;

            # Timeout after which the process is terminated.
            # timeout = 1000;

            # Controls the behaviour of the bookmark finding algorithm.
            bookmarks = {
                # Controls how far we are looking back to find bookmarks.
                exclude = [ ];
                # search_depth = 0;
            };

            module = [
                {
                    # Prints information about bookmarks in the working copies ancestors.
                    type = "Bookmarks";
                    separator = " ";
                    color = "Magenta";
                    behind_symbol = "⇡";
                    # max_bookmarks = 1;
                    # max_length = 10;
                    surround_with_quotes = false;
                }

                {
                    # Prints a warning if the working copy contains any conflicts, is divergent or hidden
                    type = "State";
                    separator = " ";

                    conflict = {
                        text = "(CONFLICT)";
                        color = "Red";
                        # bg_color = "Yellow";
                    };

                    divergent = {
                        text = "(DIVERGENT)";
                        color = "Cyan";
                        # bg_color = "Yellow";
                    };

                    hidden = {
                        text = "(HIDDEN)";
                        color = "Yellow";
                        # bg_color = "Yellow";
                    };

                    immutable = {
                        disabled = false;
                        text = "(IMMUTABLE)";
                        color = "Yellow";
                    };

                    empty = {
                        disabled = false;
                        text = "(EMPTY)";
                        color = "Yellow";
                    };
                }
                {
                    # Prints the amount of changes in the working copy
                    type = "Metrics";
                    color = "Yellow";
                    template = "[{changed}]";

                    changed_files = {
                        # suffix = "";
                        # prefix = "";
                        color = "Cyan";
                        # bg_color = "Yellow";
                    };
                }
            ];
        };
    };
}
