# Provides pkgs.local and applies repository overlays.

{ inputs, lib, ... }:
let
    inherit (lib)
        composeManyExtensions
        filterAttrs
        filterAttrsRecursive
        filesystem
        genAttrs
        isDerivation
        systems
        ;

    # Expose every package under <root>/pkgs as pkgs.local.<name>.
    packageOverlay = final: prev: {
        local = filesystem.packagesFromDirectoryRecursive {
            inherit (final.newScope { inherit inputs; }) callPackage;
            newScope = extra: final.newScope ({ inherit inputs; } // extra);
            directory = ../pkgs;
        };
    };

    # Expose historical versions from nixpkgs-multiverse as
    # `pkgs.versions.foo."<version>"`. The index sits behind a single attribute,
    # so it is only evaluated when a pinned version is requested.
    multiverseOverlay = final: prev: {
        versions =
            (inputs.nixpkgs-multiverse.lib.mkMultiverse {
                config = filterAttrsRecursive (_: value: value != null) final.config;
                system = final.stdenv.hostPlatform.system;
            }).versions;
    };

    # Repository overlays live under <root>/overlays as either foo.nix or
    # foo/default.nix. Each file must evaluate to a normal Nixpkgs overlay.
    localOverlay =
        let
            overlaysDir = ../overlays;
            overlayEntries = builtins.readDir overlaysDir;

            overlayFileFor =
                name:
                let
                    entryType = overlayEntries.${name};
                    path = overlaysDir + "/${name}";
                in
                if entryType == "regular" && builtins.match ".*\\.nix" name != null then
                    path
                else if entryType == "directory" && builtins.pathExists (path + "/default.nix") then
                    path + "/default.nix"
                else
                    null;

            overlayNames = builtins.filter (name: overlayFileFor name != null) (
                builtins.attrNames overlayEntries
            );
        in
        composeManyExtensions (map (name: import (overlayFileFor name)) overlayNames);

    overlays = [
        packageOverlay
        localOverlay
        multiverseOverlay
    ];
in
{
    flake = {
        overlays.default = composeManyExtensions overlays;

        # pkgs.local can hold pkgs-scoped helpers alongside packages. Flake package
        # outputs must stay derivations so `nix flake show` and `nix build` see a
        # valid package set.
        packages = genAttrs systems.flakeExposed (
            system:
            let
                pkgs = import inputs.nixpkgs {
                    inherit system overlays;
                    config.allowUnfree = true;
                };
            in
            filterAttrs (_: isDerivation) pkgs.local
        );
    };
}
