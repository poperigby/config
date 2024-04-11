{ ... }:

{
    imports = [
        ./fish.nix
        ./programs
    ];

    # Make programs use XDG directories whenever supported
    home.preferXdgDirectories = true;
}
