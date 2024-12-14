{ config, lib, ... }:

let
    cfg = config.poperigby.programs.git;
in
{
    options.poperigby.programs.git.enable = lib.mkEnableOption "Enable git";

    config = lib.mkIf cfg.enable {
        programs.git = {
            enable = true;
            userName = "PopeRigby";
            userEmail = "poperigby@mailbox.org";
            lfs.enable = true;
            # Makes diffs easier to read
            difftastic.enable = true;
            aliases = {
                yeet = "!git restore . && git restore --staged . && git clean -df";
                s = "status";
                sw = "switch";
                m = "switch main";
                h = "log --graph --oneline";
            };
            extraConfig = {
                color.ui = true;
                # Make the default branch name "main"
                init.defaultBranch = "main";
                push.default = "current";
                # Don't change line endings
                core.autocrlf = "false";
            };
        };
    };
}
