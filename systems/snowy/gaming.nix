{ ... }:

{
    # Enable system level gaming services/tweaks
    modules.os.gaming.enable = true;

    # Enable home level gaming programs/tweaks
    modules.home.gaming.enable = true;

    # Enable CoreCtrl, a tool to overclock AMD graphics cards and processors.
    # Automatically adds main user to corectrl group to allow launching without
    # a password.
    programs.corectrl.enable = true;
}
