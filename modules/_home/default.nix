# Settings relevant to every home

{ config, ... }:

{
    config = {
        home = {
            # Make programs use XDG directories whenever supported
            preferXdgDirectories = true;
            # Explicitly set XDG variables
            sessionVariables = {
                XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
                XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
                XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
                XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
            };
        };

        # Nicely reload system units when changing configurations
        systemd.user.startServices = "sd-switch";
    };
}
