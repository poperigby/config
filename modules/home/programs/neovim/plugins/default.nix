{ pkgs, ... }:

{
    imports = [
        ./autopairs.nix
        ./blink.nix
        ./comment.nix
        ./dap.nix
        ./fidget.nix
        ./gruvbox.nix
        ./hunk.nix
        ./highlight-colors.nix
        ./img-clip.nix
        ./lspconfig.nix
        ./lualine.nix
        ./luasnip.nix
        ./markview.nix
        ./notify.nix
        ./otter.nix
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
        dressing-nvim
        helpview-nvim
        mkdir-nvim
        none-ls-nvim
        nvim-ts-autotag
        vim-zscript
    ];
}
