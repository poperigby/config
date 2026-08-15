{ ... }:

rec {
    # Returns the path to a `.desktop` file given a package and the name of the entry.
    filePath' = pkg: entry: "${pkg}/share/applications/${entry}.desktop";

    # Returns the path to a `.desktop` file give a package. Infers the name of the
    # file based on the name of the package.
    filePath = pkg: filePath' pkg pkg.pname;
}
