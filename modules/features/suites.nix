# Opinionated bundles of aspects ("profiles")
{ den, inputs, ... }:
{
  den.aspects.suites = {
    provides.common = {
      includes = [
        den.aspects.nix
        den.aspects.system._.locale
        den.aspects.system._.zram
        den.aspects.security._.sudo
        den.aspects.services._.envfs
        den.aspects.services._.ld
        den.aspects.services._.smartd
      ];

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

    # Home Manager + user-level defaults. Kept separate so we can include it for
    # users without re-importing host-level (NixOS) settings.
    provides.common-user = {
      includes = [
        den.aspects.home-base
        den.aspects.fonts

        den.aspects.programs._.atuin
        den.aspects.programs._.bat
        den.aspects.programs._.bottom
        den.aspects.programs._.direnv
        den.aspects.programs._.fish
        den.aspects.programs._.git
        den.aspects.programs._.gpg
        den.aspects.programs._.jujutsu
        den.aspects.programs._.neovim
        den.aspects.programs._.starship
        den.aspects.programs._.tealdeer
        den.aspects.programs._.television
        den.aspects.programs._.yazi

        den.aspects.home-services._.lspmux
      ];

      homeManager =
        { lib, pkgs, config, ... }:
        let
          inherit (lib) getExe;
        in
        {
          imports = [
            inputs.nix-colors.homeManagerModules.default
            inputs.nix-index-database.homeModules.nix-index
          ];

          # https://github.com/NixOS/nix/issues/8508
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

            sessionVariables.CARGO_TARGET_DIR = "${config.xdg.cacheHome}/cargo/target";
          };

          colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
        };
    };

    provides.gui = {
        includes = [ den.aspects.services._.udisks2 ];

        nixos =
          { pkgs, ... }:
          {
            services.udisks2.enable = true;
            programs.wireshark.enable = true;
            environment.systemPackages = with pkgs; [ wireshark ];
            services.systembus-notify.enable = true;
          };
    };

    provides.gui-user = {
      includes = [
        den.aspects.programs._.discord
        den.aspects.programs._.element-desktop
        den.aspects.programs._.firefox
        den.aspects.programs._.mpv
        den.aspects.programs._.wezterm

        den.aspects.programs._.bottom-gui
        den.aspects.programs._.neovim-gui
        den.aspects.programs._.yazi-gui
      ];

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            bottles
            gimp3
            inkscape
            libreoffice
            signal-desktop
            tenacity
            tor-browser
            ungoogled-chromium
            wl-clipboard-rs
          ];

          xdg.mimeApps.enable = true;
          home.sessionVariables.NIXOS_OZONE_WL = 1;
        };
    };

    provides.gaming =
      { bethesda ? false }:
      {
        nixos =
          { ... }:
          {
          programs.steam.enable = true;
          programs.gamemode.enable = true;
          programs.gamescope = {
            enable = true;
          };
          boot.kernel.sysctl = {
            "vm.max_map_count" = 2147483642;
            "gpu_sched.sched_policy" = 0;
            "amdgpu.freesync_video" = 1;
          };
        };
      };

    provides.gaming-user =
      { bethesda ? false }:
      {
        includes =
          [
            den.aspects.programs._.mangohud
            den.aspects.home-services._.ludusavi
            den.aspects.home-services._.joystickwake
          ]
          ++ (if bethesda then [ den.aspects.programs._.morrowind ] else [ ]);

        homeManager =
          { config, lib, pkgs, ... }:
          {
            home.packages =
              with pkgs;
              [
                protontricks
                heroic
                protonplus
                libstrangle
                doomrunner
                gzdoom
                vkquake
                prismlauncher
                gpu-screen-recorder-gtk
                shadps4
              ]
              ++ lib.optionals bethesda [
                limo
              ];

            home.sessionVariables.DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";
            xdg.mimeApps.defaultApplications."application/vnd.adobe.flash.movie" = "ffdec.desktop";
          };
      };
    # GUI machines grant some extra groups to Cassidy.
    provides.gui.provides.cassidy.user.extraGroups = [
      "i2c"
      "wireshark"
    ];
  };
}
