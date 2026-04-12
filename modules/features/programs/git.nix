{ ... }:
{
    den.aspects.programs.provides.git.homeManager =
        { privateInfo, ... }:
        {
            programs = {
                git = {
                    enable = true;
                    lfs.enable = true;
                    settings = {
                        user = {
                            name = privateInfo.poperigby.name;
                            email = privateInfo.poperigby.email;
                        };
                        aliases = {
                            yeet = "!git restore . && git restore --staged . && git clean -df";
                            s = "status";
                            sw = "switch";
                            m = "switch main";
                            h = "log --graph --oneline";
                        };
                        core.autocrlf = "false";
                        color.ui = true;
                        column.ui = "auto";
                        branch.sort = "-committerdate";
                        tag.sort = "version:refname";
                        init.defaultBranch = "main";
                        diff = {
                            algorithm = "histogram";
                            colorMoved = "plain";
                            mnemonicPrefix = true;
                            renames = true;
                        };
                        push = {
                            default = "simple";
                            autoSetupRemote = true;
                            followTags = true;
                        };
                        fetch = {
                            prune = true;
                            pruneTags = true;
                            all = true;
                        };
                    };
                };

                difftastic = {
                    enable = true;
                    git.enable = true;
                };
            };
        };
}
