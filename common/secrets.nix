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
        # This will automatically import SSH keys as age keys
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
}
