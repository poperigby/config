{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.neovim;
    nvim = "${config.programs.neovim.finalPackage}/bin/nvim";
    nvimDir = "${config.poperigby.configDir}/modules/home/programs/neovim";
in
{
    options.poperigby.programs.neovim.enable = lib.mkEnableOption "Enable Neovim";

    config = lib.mkIf cfg.enable {
        programs.neovim = {
            enable = true;
            # Set EDITOR to nvim
            defaultEditor = true;
            # Alias vi and vim to nvim
            viAlias = true;
            vimAlias = true;
            # Extra packages available to Neovim
            extraPackages = with pkgs; [
                # TreeSitter needs this to install parsers
                gcc
                # Some plugins/tools need these to install
                cargo
                gnumake
                nodePackages.npm
                unzip
                # Language servers
                lua-language-server
                nixd
                rust-analyzer
            ];
            plugins = [
                # All other plugins are managed by lazy-nvim
                pkgs.vimPlugins.lazy-nvim
            ];
        };

        home.sessionVariables = {
            # Make Neovim my pager for the man command
            MANPAGER = "${nvim} -c 'Man!' -o -";
            # Make Neovim my systemd editor
            SYSTEMD_EDITOR = "${nvim}";
        };

        xdg.configFile = {
            # Symlink Neovim config to ~/.config/nvim
            "nvim" = {
                source = ./config;
                recursive = true;
            };
            # Raw symlink to the plugin manager lock file, so that it stays writeable
            "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";
        };

        # Setup plugins with Lazy during activation
        home.activation.neovim = lib.home-manager.hm.dag.entryAfter [ "linkGeneration" ] # bash
        ''
            LOCK_FILE=$(readlink -f ~/.config/nvim/lazy-lock.json)
            STATE_DIR=~/.local/state/nix/
            STATE_FILE=$STATE_DIR/lazy-lock-checksum

            [ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
            [ ! -f $STATE_FILE ] && touch $STATE_FILE

            HASH=$(nix-hash --flat $LOCK_FILE)

            if [ "$(cat $STATE_FILE)" != "$HASH" ]; then
                echo "Syncing neovim plugins"
                run ${nvim} --headless "+Lazy! restore" +qa
                run echo $HASH > $STATE_FILE
            else
                verboseEcho "Neovim plugins already synced, skipping"
            fi
        '';
    };
}
