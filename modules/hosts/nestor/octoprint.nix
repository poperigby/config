{ ... }:

{
    den.aspects.nestor.nixos =
        {
            config,
            pkgs,
            ...
        }:
        let
            printerProfile = pkgs.writeText "octoprint-default-printer.profile" (
                builtins.toJSON {
                    axes = {
                        e = {
                            inverted = false;
                            speed = 300;
                        };
                        x = {
                            inverted = false;
                            speed = 6000;
                        };
                        y = {
                            inverted = false;
                            speed = 6000;
                        };
                        z = {
                            inverted = false;
                            speed = 200;
                        };
                    };
                    color = "default";
                    extruder = {
                        count = 1;
                        defaultExtrusionLength = 5;
                        nozzleDiameter = 0.4;
                        offsets = [
                            [
                                0.0
                                0.0
                            ]
                        ];
                        sharedNozzle = false;
                    };
                    heatedBed = true;
                    heatedChamber = false;
                    id = "_default";
                    model = "Original Prusa i3 MK3S+";
                    name = "Prusa";
                    volume = {
                        custom_box = {
                            x_max = 250.0;
                            x_min = 0.0;
                            y_max = 210.0;
                            y_min = -4.0;
                            z_max = 210.0;
                            z_min = 0.0;
                        };
                        depth = 210.0;
                        formFactor = "rectangular";
                        height = 210.0;
                        origin = "lowerleft";
                        width = 250.0;
                    };
                }
            );
        in
        {
            services.octoprint = {
                enable = true;
                extraConfig = {
                    printerProfiles.default = "_default";
                    serial = {
                        additionalPorts = [ "/dev/ttyAMA0" ];
                        autoconnect = true;
                        baudrate = 0;
                        port = "AUTO";
                    };
                    server = {
                        firstRun = false;
                        onlineCheck.enabled = true;
                        pluginBlacklist.enabled = true;
                        seenWizards = {
                            backup = null;
                            classicwebcam = 1;
                            corewizard = 4;
                            tracking = null;
                        };
                    };
                    temperature.profiles = [
                        {
                            bed = 100;
                            chamber = null;
                            extruder = 210;
                            name = "ABS";
                        }
                        {
                            bed = 60;
                            chamber = null;
                            extruder = 180;
                            name = "PLA";
                        }
                    ];
                };
                openFirewall = true;
                plugins =
                    plugins:
                    let
                        # Compatibility dependencies for third-party plugins on Python 3.13.
                        pythonFuture = plugins.future.overridePythonAttrs (_: {
                            disabled = false;
                            doCheck = false;
                            pythonImportsCheck = [ ];
                        });
                        pluginDependencies = [
                            plugins.pillow
                            plugins.standard-imghdr
                            pythonFuture
                        ];
                    in
                    (with plugins; [
                        bedlevelvisualizer
                        displayprogress
                        navbartemp
                        prusaslicerthumbnails
                        simpleemergencystop
                        themeify
                    ])
                    ++ pluginDependencies;
            };

            users.users.octoprint.extraGroups = [ "video" ];

            systemd.tmpfiles.rules = [
                "d ${config.services.octoprint.stateDir}/printerProfiles 0750 ${config.services.octoprint.user} ${config.services.octoprint.group} - -"
                "C+ ${config.services.octoprint.stateDir}/printerProfiles/_default.profile 0600 ${config.services.octoprint.user} ${config.services.octoprint.group} - ${printerProfile}"
                "C+ ${config.services.octoprint.stateDir}/users.yaml 0600 ${config.services.octoprint.user} ${config.services.octoprint.group} - ${config.sops.templates.octoprint-users.path}"
            ];

            sops = {
                secrets."nestor/octoprint/admin_password" = { };
                templates.octoprint-users.content = ''
                    _version: 2
                    admin:
                      active: true
                      apikey: null
                      groups:
                      - admins
                      - users
                      password: '${config.sops.placeholder."nestor/octoprint/admin_password"}'
                      permissions: []
                      roles:
                      - admin
                      - user
                      settings: {}
                '';
            };
        };
}
