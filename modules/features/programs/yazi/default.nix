{ ... }:
{
    den.aspects.programs.provides.yazi = {
        homeManager =
            { lib, pkgs, ... }:
            let
                inherit (lib)
                    getExe
                    listToAttrs
                    readFile
                    removeSuffix
                    ;

                ouchExe = getExe pkgs.ouch;
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
                                run = "${ouchExe} d -y %s";
                                desc = "Extract here with ouch";
                                for = "unix";
                            }
                        ];
                        plugin.prepend_previewers = [
                            {
                                mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
                                run = ouchExe;
                            }
                        ];
                    };
                    plugins = listToAttrs (
                        map
                            (plugin: {
                                name = removeSuffix ".yazi" plugin.pname;
                                value = plugin;
                            })
                            (
                                with pkgs.yaziPlugins;
                                [
                                    ouch
                                    starship
                                    yamb
                                ]
                            )
                    );
                    keymap.mgr.prepend_keymap = [
                        {
                            on = [ "C" ];
                            run = "plugin ouch";
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
                    ];
                };
            };

        provides.gui.homeManager =
            { lib, pkgs, ... }:
            let
                inherit (lib) getExe;
            in
            {
                programs.yazi.keymap.mgr.prepend_keymap = [
                    {
                        on = [ "<C-n>" ];
                        run = "shell --orphan -- ${getExe pkgs.ripdrag} -x %s";
                        desc = "Open ripdrag for dragging and dropping";
                    }
                ];

                xdg.desktopEntries.yazi = {
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
    };
}
