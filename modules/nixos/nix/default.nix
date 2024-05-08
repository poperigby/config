{ ... }:

{
    nix = {
        settings = {
            # Enable New CLI and Flakes
            experimental-features = [ "nix-command" "flakes" ];
            # Optimize storage
            auto-optimise-store = true;
        };
        # Perform garbage collection weekly to maintain low disk usage
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 1w";
        };
    };
}
