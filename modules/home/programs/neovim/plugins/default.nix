{ pkgs, ... }:

{
    imports = [
        ./cmp.nix
        ./comment.nix
        ./dap.nix
        ./fidget.nix
        ./gruvbox.nix
        ./hardtime.nix
        ./highlight-colors.nix
        ./hunk.nix
        ./img-clip.nix
        ./indent.nix
        ./lspconfig.nix
        ./lualine.nix
        ./luasnip.nix
        ./markview.nix
        ./notify.nix
        ./otter.nix
        ./pairs.nix
        ./telescope.nix
        ./todo-comments.nix
        ./toggleterm.nix
        ./treesitter.nix
        ./typescript-tools.nix
        ./ufo.nix
        ./which-key.nix
        ./yazi.nix
    ];

    # Plugins that require no configuration
    programs.neovim.plugins = with pkgs.vimPlugins; [
        helpview-nvim
        mkdir-nvim
        none-ls-nvim
        nvim-ts-autotag
        vim-zscript
    ];
}
