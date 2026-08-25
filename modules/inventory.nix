# Defines all hosts, users, and homes
#
# Specific configuration goes in either hosts/ or users/

{ inputs, ... }:
{
    den.hosts = {
        aarch64-linux = {
            # 3D printer
            nestor = {
                instantiate = inputs.nixos-raspberrypi.lib.nixosSystem;
                users.cassidy = { };
            };
        };
        x86_64-linux = {
            # Laptop
            allan = {
                users.cassidy = { };
            };
            # Living room desktop
            calculus = {
                users.shane = { };
            };
            # Server
            haddock = {
                users = {
                    cassidy = { };
                    julian = { };
                    shane = { };
                };
            };
            # Desktop
            snowy = {
                users.cassidy = { };
            };
            # Installer/recovery ISO
            skut = { };
        };
    };
}
