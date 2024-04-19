{ builtins, ... }:

{
    programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        # I want to be able to quickly copy themes without converting
        # them to nix first.
        theme = builtins.fromTOML builtins.readFile "theme.toml";
    };
}
