{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        optionals
    ;

    cfg = config.poperigby.users.cassidy;
    virtualization = config.poperigby.services.virtualization.enable;
    printing = config.poperigby.hardware.printing.enable;
in
{
    options.poperigby.users.cassidy.enable = mkEnableOption "Cassidy user";

    config = mkIf cfg.enable {
        sops.secrets."common/users/cassidy/password".neededForUsers = true;

        # Set up me 🙂
        users.users.cassidy = {
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."common/users/cassidy/password".path;
            description = "Cassidy Wilson";
            extraGroups = [
                "wheel"
                "adbusers"
            ] ++ optionals virtualization [
                "libvirtd"
            ] ++ optionals printing [
                # Rootless CUPS
                "lp"
            ];
        };

        # Tell Home Manager information about the user
        home-manager.users.cassidy.home = {
            username = "cassidy";
            homeDirectory = "/home/cassidy";
        };
    };
}
