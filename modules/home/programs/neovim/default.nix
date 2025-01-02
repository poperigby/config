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
          typescript
          vscode-langservers-extracted
          yaml-language-server
        ];
        extraLuaConfig = # lua
          ''
            require("options")
            require("misc")
            require("mappings")
            require("filetype")
            ${lib.optionalString gui "require(\"gui\")"}
          '';
      };
      neovide = mkIf gui {
        enable = true;
        settings = {
          font = {
            normal = [ "JetBrainsMono Nerd Font" ];
            size = 11.0;
            # Disable ligatures 🤢
            features."JetBrainsMono Nerd Font" = [
              "-calt"
              "-clig"
              "-liga"
            ];
          };
        };
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
    };

    home.packages = [
      # Disable built-in Neovim wrapper .desktop entry
      (lib.hiPrio (
        pkgs.runCommand "nvim.desktop-hide" { } ''
          mkdir -p "$out/share/applications"
          cat "${config.programs.neovim.finalPackage}/share/applications/nvim.desktop" > "$out/share/applications/nvim.desktop"
          echo "Hidden=1" >> "$out/share/applications/nvim.desktop"
        ''
      ))
    ];
  };
}
