{
    config,
    lib,
    ...
}:

let
    inherit (lib) mkEnableOption mkIf;

    cfg = config.custom.desktops.cosmic;
in
{
    options.custom.desktops.cosmic = {
        enable = mkEnableOption "COSMIC DE";
    };

    config = mkIf cfg.enable {
        services = {
            desktopManager.cosmic.enable = true;
            displayManager.cosmic-greeter.enable = true;
        };
    };
}
