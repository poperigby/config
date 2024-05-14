{ ... }:

{
    # Dynamically populates contents of /bin and /usr/bin, allowing
    # programs that assume FHS to work.
    services.envfs.enable = true;

    # Specifies where my flake is located for nh
    environment.sessionVariables.FLAKE = "/home/cassidy/nixos";
}
