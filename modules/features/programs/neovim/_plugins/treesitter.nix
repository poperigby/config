{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
            type = "lua";
            config = # lua
                ''
                    vim.api.nvim_create_autocmd("FileType", {
                        callback = function(args)
                            local filetype = args.match
                            local lang = vim.treesitter.language.get_lang(filetype)
                            if vim.treesitter.language.add(lang) then
                                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                                vim.treesitter.start()
                            end
                        end
                      })
                '';
        }
    ];
}
