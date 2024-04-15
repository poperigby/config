{ inputs, ... }:

{
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../modules/home;
    };

}
