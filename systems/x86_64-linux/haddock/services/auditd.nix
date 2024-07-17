{ lib, ... }:

{
    security = {
        audit = {
            enable = true;
            rules = [
                "-a exit,always -F arch=b64 -S execve"
                "-a exit,always -F arch=b32 -S execve"
            ];
        };
        auditd.enable = true;
    };

    # A group for users that can read audit logs
    users.groups.audit = {};

    environment.etc."audit/auditd.conf".text =  lib.generators.toKeyValue { mkKeyValue = lib.generators.mkKeyValueDefault {} " = "; } {
        log_group = "audit";
        space_left = 1000;
        space_left_action = "rotate";
    };
}
