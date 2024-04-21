{ ... }:

{
    programs.starship = {
        enable = true;
        settings = {
            # Don't print a new line at the start of the prompt
            add_newline = false;
            character = {
                success_symbol = "[❯](green)";
                error_symbol = "[❯](red)";
            };
        };
    };
}
