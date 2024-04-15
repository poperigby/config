{ inputs, ... }:

{
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../modules/home;
    };

    # Enable River WM
    modules.home.river.enable = true;
}
