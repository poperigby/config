{ inputs, ... }:

{
    # Setup home-manager
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../home;
    };
}
