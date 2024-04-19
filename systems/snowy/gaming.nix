{ ... }:

{
    # Enable common gaming services/tweaks
    common.os.gaming.enable = true;
    # Enable CoreCtrl, a tool to overclock AMD graphics cards and processors
    # Automatically adds main user to corectrl group to allow launching without
    # a password.
    programs.corectrl.enable = true;
}
