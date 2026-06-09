{ ... }:
{
    den.aspects.security.provides.run0.nixos =
        { lib, ... }:
        {
            security = {
                pam.services.systemd-run0 = { };

                run0.enableSudoAlias = true;
                sudo.enable = lib.mkForce false;

                polkit.extraConfig = # JavaScript
                    ''
                        polkit.addRule(function(action, subject) {
                            if (
                                action.id == "org.freedesktop.systemd1.manage-units" ||
                                "org.freedesktop.systemd1.manage-unit-files" &&
                                subject.isInGroup("wheel")
                            ) {
                                polkit.log("ADMIN KEEP! :)");
                                return polkit.Result.AUTH_ADMIN_KEEP;
                            }
                        });
                    '';

                polkit.debug = true;
            };
        };
}
