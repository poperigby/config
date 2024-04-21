{ ... }:

{
    boot.loader = {
        systemd-boot = {
            enable = true;
            # Limit the number of generations to keep
            configurationLimit = 3;
        };
        efi.canTouchEfiVariables = true;
    };
}
