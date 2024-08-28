{ pkgs, ... }:

{
    imports = [
        ./autopairs.nix
        ./comment.nix
        ./fidget.nix
        ./gruvbox.nix
        ./highlight-colors.nix
        ./lualine.nix
        ./luasnip.nix
        ./markview.nix
        ./telescope.nix
        ./todo-comments.nix
        ./toggleterm.nix
        ./treesitter.nix
        ./trouble.nix
        ./ufo.nix
        ./which-key.nix
    ];

    # Plugins that require no configuration
    programs.neovim.plugins = with pkgs.vimPlugins; [
        dressing-nvim
        mkdir-nvim
        none-ls-nvim
        nvim-lspconfig
        nvim-nu
        nvim-ts-autotag
        typst-vim
        vim-caddyfile  
    ];
}
