{ ... }:

{
    programs.bat = {
        enable = true;
        config = {
            theme = "gruvbox-dark";
            # Don't show none of them fancy pants line numbers or such
            plain = true;
        };
    };
}
