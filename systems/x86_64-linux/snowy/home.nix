{ ... }:

{
    home-manager.users.cassidy.poperigby = {
        suites = {
            common.enable = true;
            desktop.enable = true;
            gaming = {
                enable = true;
                amd.enable = true;
            };
        };
    };
}
