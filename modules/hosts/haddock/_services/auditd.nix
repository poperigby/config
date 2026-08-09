{ ... }:

{
    security = {
        auditd = {
            enable = true;
            settings = {
                log_group = "audit";
                # Maximum log file size in megabytes
                max_log_file = 1000;
                max_log_file_action = "rotate";
                # The amount of log files to keep around
                num_logs = 3;
                space_left = 10000;
            };
        };
        audit = {
            enable = true;
            # Hold the early-boot execve burst until auditd starts draining events.
            backlogLimit = 16384;
            rules = [
                # Log all 64/32-bit binary executions
                "-a exit,always -F arch=b64 -S execve"
                "-a exit,always -F arch=b32 -S execve"
            ];
        };
    };

    # A group for users that can read audit logs
    users.groups.audit = { };
}
