{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.users;
in
{
    options.poperigby.users.enable = mkEnableOption "user settings";

    config = mkIf cfg.enable {
        # Don't allow changing users with normal commands, allowing Nix to
        # be the single source of truth for users.
        users.mutableUsers = false;
    };
}
