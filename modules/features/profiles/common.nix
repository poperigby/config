{ den, inputs, ... }:
{
    flake-file.inputs = {
        nix-colors.url = "github:misterio77/nix-colors";
        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.common = {
        includes = with den.aspects; [
            programs._.bottom
            programs._.claude-code
            programs._.direnv
            programs._.fish
            programs._.git
            programs._.gpg
            programs._.jujutsu
            programs._.neovim
            programs._.nix
            programs._.starship
            programs._.television
            programs._.yazi
            security._.sudo
        ];

        homeManager =
            {
                lib,
                pkgs,
                config,
                ...
            }:
            let
                inherit (lib) getExe;
            in
            {
                imports = [
                    inputs.nix-colors.homeManagerModules.default
                    inputs.nix-index-database.homeModules.nix-index
                ];

                nix.gc = {
                    automatic = true;
                    options = "--delete-older-than 7d";
                };

                programs = {
                    bat = {
                        enable = true;
                        config = {
                            theme = "gruvbox-dark";
                            plain = true;
                        };
                    };
                    eza.enable = true;
                    home-manager.enable = true;
                    nix-index.enable = true;
                    nix-index-database.comma.enable = true;
                    pay-respects.enable = true;
                    tealdeer = {
                        enable = true;
                        settings.updates.auto_update = true;
                    };
                    zoxide = {
                        enable = true;
                        options = [ "--cmd cd" ];
                    };
                };

                home = {
                    preferXdgDirectories = true;
                    packages = with pkgs; [
                        asciinema
                        binsider
                        caligula
                        delta
                        devenv
                        dmidecode
                        doggo
                        dos2unix
                        dust
                        fd
                        ffmpeg
                        file
                        hydra-check
                        imagemagick
                        jq
                        just
                        lazygit
                        local.new-project
                        local.toml2nix
                        local.yaml2nix
                        net-tools
                        nix-init
                        nixfmt
                        nurl
                        ouch
                        parted
                        pciutils
                        rename
                        ripgrep
                        sops
                        systemctl-tui
                        trashy
                        tree
                        treefmt
                        typst
                        usbutils
                        vimv-rs
                        xh
                    ];

                    shellAliases = {
                        cat = "bat";
                        find = "fd";
                        grep = "rg";
                        jrn = "sudo journalctl";
                        license = getExe pkgs.license-generator;
                        py = "python";
                        sys = "sudo systemctl";
                        syu = "systemctl --user";
                        yt = getExe pkgs.yt-dlp;
                    };

                    sessionVariables = {
                        XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
                        XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
                        XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
                        XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
                        CARGO_HOME = "${config.xdg.dataHome}/cargo";
                        CARGO_TARGET_DIR = "${config.xdg.cacheHome}/cargo/target";
                        DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
                        PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
                        WINEPREFIX = "${config.xdg.dataHome}/wine";
                    };
                };

                systemd.user.startServices = "sd-switch";
                colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
            };

        nixos =
            { pkgs, ... }:
            {
                programs.appimage = {
                    enable = true;
                    binfmt = true;
                };

                boot.kernelPackages = pkgs.linuxPackages_latest;

                zramSwap.enable = true;

                i18n.defaultLocale = "en_US.UTF-8";

                # Don't allow changing users with normal commands. Nix is the source of truth.
                users.mutableUsers = false;
            };

    };
}
