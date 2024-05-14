{ config, lib, ... }:

let
  cfg = config.poperigby.users;
in
{
    options.poperigby.users.enable = lib.mkEnableOption "Enable user settings";

    config = lib.mkIf cfg.enable {
        # Don't allow changing users with normal commands, allowing Nix to
        # be the single source of truth for users.
        users.mutableUsers = false;
    };
}
