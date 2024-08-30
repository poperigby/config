{ pkgs, ... }:

{
    imports = [
        ./autopairs.nix
        ./cmp.nix
        ./comment.nix
        ./fidget.nix
        ./gruvbox.nix
        ./highlight-colors.nix
        ./img-clip.nix
        ./lspconfig.nix
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
        ./yazi.nix
    ];

    # Plugins that require no configuration
    programs.neovim.plugins = with pkgs.vimPlugins; [
        dressing-nvim
        helpview-nvim
        mkdir-nvim
        none-ls-nvim
        nvim-ts-autotag
    ];
}
