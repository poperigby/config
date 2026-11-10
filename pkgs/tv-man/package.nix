{
    pkgs,
    ...
}:

pkgs.writeShellApplication {
    name = "tv-man";
    text = ''
        man_db=${pkgs.man-db}/bin
    ''
    + builtins.readFile ./script.sh;
}
