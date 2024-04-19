{ builtins, ... }:

{
    programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        theme = builtins.fromTOML builtins.readFile "theme.toml";
    };
}
