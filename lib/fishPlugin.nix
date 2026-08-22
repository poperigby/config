{ ... }:

# Define a fish plugin from the given package.
pkg: {
    name = pkg.pname;
    src = pkg.src;
}
