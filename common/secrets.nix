{ inputs, ... }:

{
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];

    # Secret management
    sops = {
        defaultSopsFile = ../secrets.yaml;
        defaultSopsFormat = "yaml";
        # This is the default AGE key that will be used for bootstrapping the system
        age.keyFile = "/var/lib/sops-nix/age-key.txt";
        # This will automatically import SSH host keys as AGE keys
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
}
