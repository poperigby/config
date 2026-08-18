{ ... }:

{
    den.aspects.hardware.provides.android = {
        nixos =
            { lib, pkgs, ... }:
            {
                environment = {
                    shellAliases.adb = "${lib.getExe' pkgs.android-tools "adb"} HOME=$XDG_DATA_HOME/android adb";
                    variables.ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
                };
            };

        user.extraGroups = [ "adbusers" ];
    };
}
