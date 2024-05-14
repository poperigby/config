{ ... }:

{
    # Dynamically populates contents of /bin and /usr/bin, allowing
    # programs that assume FHS to work.
    services.envfs.enable = true;
}
