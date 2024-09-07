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
            earlyoom.enable = true;
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
                            # Undervolt my GPU
                            max_voltage = 1100;
                            max_core_clock = 1755;
                            # Should help with FreeSync not working
                            performance_level = "manual";
                            power_profile_mode_index = 1;
                            power_states = {
                                memory_clock = [ 0 1 2 3 ];
                                core_clock = [ 0 1 ];
                            };
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

    programs.adb.enable = true;

    time.timeZone = "America/Los_Angeles";

    networking.networkmanager.enable = true;

    # TODO: Allow key-only auth
    # Having SSHD enabled is pretty handy sometimes
    #services.openssh.enable = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
