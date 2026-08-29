{ lib, ... }:

let
    inherit (lib)
        filterAttrs
        mapAttrs
        toSentenceCase
        ;

    templatesDir = ../templates;
    entries = if builtins.pathExists templatesDir then builtins.readDir templatesDir else { };
    templateDirs = filterAttrs (_: type: type == "directory") entries;
in
{
    flake.templates = mapAttrs (name: _: {
        path = templatesDir + "/${name}";
        description = toSentenceCase name;
    }) templateDirs;
}
