{ ... }:

{
    # Enable common gaming services/tweaks
    modules.os.gaming.enable = true;
    # Enable MangoHUD
    modules.home.mangohud.enable = true;
    # Enable CoreCtrl, a tool to overclock AMD graphics cards and processors.
    # Automatically adds main user to corectrl group to allow launching without
    # a password.
    programs.corectrl.enable = true;
}
