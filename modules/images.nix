{
    self,
    lib,
    den,
    ...
}:
let
    inherit (lib)
        concatMapAttrs
        filterAttrs
        mkOption
        nameValuePair
        types
        ;

    image =
        hostName: images: image:
        nameValuePair hostName self.nixosConfigurations.${hostName}.config.system.build.images.${image};

    imagesForHost =
        hostName: host:
        let
            inherit (host) images;
        in
        builtins.listToAttrs (map (image hostName images) images);

    imagesForSystem =
        _system: hosts: concatMapAttrs imagesForHost (filterAttrs (_: host: host.images != [ ]) hosts);
in
{
    # Allows hosts to declare what images they want to expose in inventory.nix
    den.schema.host.imports = [
        (
            { ... }:
            {
                options.images = mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                    description = "NixOS image variants to publish as flake outputs.";
                };
            }
        )
    ];

    flake.images = concatMapAttrs (
        system: hosts:
        let
            images = imagesForSystem system hosts;
        in
        if images == { } then { } else { ${system} = images; }
    ) den.hosts;
}
