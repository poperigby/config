{ ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
    ];

    poperigby = {
        hardware = {
            audio.enable = true;
            bluetooth.enable = true;
            corsair.enable = true;
            printing.enable = true;
            scanning.enable = true;
        };
        services = {
            backups = {
                enable = true;
                paths = [
                    "/home/*/.local/state/backups"
                ];
            };
            geolocation.enable = true;
            lact = {
                enable = true;
                gpuOverclock.enable = true;
                settings = {
                    daemon = {
                        log_level = "info";
                        admin_groups = [ "wheel" "sudo" ];
                        disable_clocks_cleanup = false;
                    };
                    apply_settings_timer = 5;
                    gpus = {
                        "1002:731F-1DA2:E411-0000:0d:00.0" = {
                            fan_control_enabled = false;
                            pmfw_options = {};
                            # Undervolt my GPU
                            max_voltage = 1100;
                            # Should help with FreeSync not working
                            performance_level = "high";
                            power_states = {};
                        };
                    };
                };
            };
            virtualization.enable = true;
        };
        suites = {
            common.enable = true;
            gaming.enable = true;
            gui.enable = true;
        };
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # TODO: Allow key-only auth
    # Having SSHD enabled is pretty handy sometimes
    #services.openssh.enable = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
