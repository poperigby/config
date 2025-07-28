{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.neovim;
  gui = config.custom.suites.gui.enable;
  nvim = getExe config.programs.neovim.finalPackage;
in
{
  options.custom.programs.neovim.enable = mkEnableOption "Neovim";

  config = mkIf cfg.enable {
    programs = {
      neovim = {
        enable = true;
        # Set EDITOR to nvim
        defaultEditor = true;
        # Alias vi and vim to nvim
        viAlias = true;
        vimAlias = true;
        # Extra packages available to Neovim
        extraPackages = with pkgs; [
          # Language servers
          bash-language-server
          clang-tools
          csharp-ls
          harper
          lua-language-server
          luajitPackages.teal-language-server
          nixd
          nodejs
          pyright
          rust-analyzer
          tinymist
          typescript
          vscode-langservers-extracted
          yaml-language-server
          slint-lsp
        ];
        extraLuaConfig = # lua
          ''
            require("options")
            require("misc")
            require("mappings")
            require("filetype")
          '';
      };
    };

    home.sessionVariables = {
      # Make Neovim my pager for the man command
      MANPAGER = "${nvim} -c 'Man!' -o -";
      # Make Neovim my systemd editor
      SYSTEMD_EDITOR = "${nvim}";
    };

    xdg = {
      # Symlink Neovim config to ~/.config/nvim/lua
      configFile."nvim/lua" = {
        source = ./config;
        recursive = true;
      };
      desktopEntries.nvim = mkIf gui {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "${getExe pkgs.wezterm} start nvim %F";
        terminal = false;
        type = "Application";
        icon = "nvim";
        categories = [
          "Utility"
          "TextEditor"
        ];
        mimeType = [ "text/plain" ];
      };
    };
  };
}
