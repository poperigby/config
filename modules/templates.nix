{ lib, ... }:

let
    templatesDir = ../templates;
    entries = if builtins.pathExists templatesDir then builtins.readDir templatesDir else { };
    templateDirs = lib.filterAttrs (_: type: type == "directory") entries;
in
{
    flake.templates = lib.mapAttrs (name: _: {
        path = templatesDir + "/${name}";
        description = name;
    }) templateDirs;
}
