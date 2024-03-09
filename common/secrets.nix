{ inputs, ... }:

{
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];

    # Secret management
    sops = {
        defaultSopsFile = ../secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "/home/cassidy/.config/sops/age/keys.txt";
    };
}
