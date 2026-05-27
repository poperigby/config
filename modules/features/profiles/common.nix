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
        includes = [
            den.aspects.nix
            den.aspects.programs._.jujutsu
            den.aspects.security._.run0
            den.aspects.security._.sudo
            den.aspects.services._.envfs
            den.aspects.services._.ld
            den.aspects.services._.smartd
            den.aspects.system._.locale
            den.aspects.system._.zram
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
                    eza.enable = true;
                    direnv.enable = true;
                    home-manager.enable = true;
                    nix-index.enable = true;
                    nix-index-database.comma.enable = true;
                    pay-respects.enable = true;
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
                        dust
                        fd
                        ffmpeg
                        file
                        imagemagick
                        jq
                        just
                        lazygit
                        nix-init
                        nixfmt
                        nurl
                        (ouch.override { enableUnfree = true; })
                        parted
                        pciutils
                        rename
                        ripgrep
                        sops
                        systemctl-tui
                        trashy
                        tree
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
                        nps = "nix search nixpkgs";
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
                        CARGO_TARGET_DIR = "${config.xdg.cacheHome}/cargo/target";
                    };
                };

                systemd.user.startServices = "sd-switch";
                colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
            };

        nixos =
            { pkgs, ... }:
            {
                boot = {
                    kernelPackages = pkgs.linuxPackages_latest;
                    kernelParams = [
                        # https://github.com/NixOS/nixpkgs/issues/312452
                        "systemd.mask=systemd-vconsole-setup.service"
                        "systemd.mask=dev-tpmrm0.device"
                    ];
                };

                # Don't allow changing users with normal commands; Nix is the source of truth.
                users.mutableUsers = false;
            };

    };
}
