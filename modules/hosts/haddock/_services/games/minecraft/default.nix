{
    inputs,
    lib,
    pkgs,
    system,
    ...
}:

{
    services.minecraft-servers = {
        enable = true;
        eula = true;
        openFirewall = true;
        dataDir = "/var/lib/minecraft";
        managementSystem.systemd-socket.enable = true;
        servers.fabric = {
            enable = true;
            package = inputs.nix-minecraft.legacyPackages.${system}.fabricServers.fabric-1_21_4;
            serverProperties = {
                server-name = "Haddock";
                difficulty = "normal";
                allow-cheats = true;
            };
            symlinks = {
                "ops.json" = (pkgs.formats.json { }).generate "ops.json" [
                    {
                        uuid = "856e015c-7937-49d8-80dc-35ccdf96e3c2";
                        name = "jujubunicorn";
                        level = 4;
                        bypassesPlayerLimit = true;
                    }
                    {
                        uuid = "945a016d-b341-453c-8dca-cc16091088ca";
                        name = "PopeRigby";
                        level = 4;
                        bypassesPlayerLimit = true;
                    }
                ];
                mods = import ./mods.nixlib { inherit pkgs lib; };
            };
        };
    };
}
