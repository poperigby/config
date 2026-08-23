{ ... }:
{
    den.aspects.programs.provides.yazi.homeManager =
        {
            lib,
            pkgs,
            user,
            ...
        }:
        let
            inherit (lib) getExe readFile;
            hasGui = lib.local.aspects.hasGui user;
        in
        {
            programs.yazi = {
                enable = true;
                enableFishIntegration = true;
                shellWrapperName = "yy";
                theme = fromTOML (readFile ./theme.toml);
                initLua = ./init.lua;
                settings = {
                    mgr = {
                        sort_by = "mtime";
                        sort_reverse = true;
                        sort_dir_first = false;
                    };
                    opener.extract = [
                        {
                            run = "ouch d -y \"$@\"";
                            desc = "Extract here with ouch";
                            for = "unix";
                        }
                    ];
                    plugin.prepend_previewers = [
                        {
                            mime = "application/*zip";
                            run = "ouch";
                        }
                        {
                            mime = "application/x-tar";
                            run = "ouch";
                        }
                        {
                            mime = "application/x-bzip2";
                            run = "ouch";
                        }
                        {
                            mime = "application/x-7z-compressed";
                            run = "ouch";
                        }
                        {
                            mime = "application/x-rar";
                            run = "ouch";
                        }
                        {
                            mime = "application/x-xz";
                            run = "ouch";
                        }
                    ];
                };
                plugins = {
                    yamb = pkgs.fetchFromGitHub {
                        owner = "h-hg";
                        repo = "yamb.yazi";
                        rev = "22af0033be18eead7b04c2768767d38ccfbaa05b";
                        hash = "sha256-NMxZ8/7HQgs+BsZeH4nEglWsRH2ibAzq7hRSyrtFDTA=";
                    };
                    ouch = pkgs.fetchFromGitHub {
                        owner = "ndtoan96";
                        repo = "ouch.yazi";
                        rev = "v0.6.0";
                        hash = "sha256-mtXl76a54Deg4cyrD0wr++sD/5b/kCsnJ+ngM6OokTc=";
                    };
                    starship = pkgs.yaziPlugins.starship;
                };
                keymap.mgr.prepend_keymap = [
                    {
                        on = [ "C" ];
                        run = "plugin ouch --args=zip";
                        desc = "Compress with ouch";
                    }
                    {
                        on = [
                            "u"
                            "a"
                        ];
                        run = "plugin yamb --args=save";
                        desc = "Add bookmark";
                    }
                    {
                        on = [
                            "u"
                            "g"
                        ];
                        run = "plugin yamb --args=jump_by_key";
                        desc = "Jump bookmark by key";
                    }
                    {
                        on = [
                            "u"
                            "G"
                        ];
                        run = "plugin yamb --args=jump_by_fzf";
                        desc = "Jump bookmark by fzf";
                    }
                    {
                        on = [
                            "u"
                            "d"
                        ];
                        run = "plugin yamb --args=delete_by_key";
                        desc = "Delete bookmark by key";
                    }
                    {
                        on = [
                            "u"
                            "D"
                        ];
                        run = "plugin yamb --args=delete_by_fzf";
                        desc = "Delete bookmark by fzf";
                    }
                    {
                        on = [
                            "u"
                            "A"
                        ];
                        run = "plugin yamb --args=delete_all";
                        desc = "Delete all bookmarks";
                    }
                    (lib.mkIf hasGui {
                        on = [ "<C-n>" ];
                        run = "shell '${getExe pkgs.ripdrag} \"$@\" -x 2>/dev/null &' --confirm";
                        description = "Open ripdrag for dragging and dropping";
                    })
                ];
            };

            xdg.desktopEntries.yazi = lib.mkIf hasGui {
                name = "Yazi";
                genericName = "File Browser";
                exec = "${getExe pkgs.yazi} %f";
                icon = ./icon.png;
                terminal = true;
                type = "Application";
                categories = [
                    "System"
                    "FileTools"
                    "FileManager"
                ];
                mimeType = [ "inode/directory" ];
            };
        };
}
