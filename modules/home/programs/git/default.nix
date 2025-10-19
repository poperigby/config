{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.git;
in
{
  options.custom.programs.git.enable = mkEnableOption "Enable git";

  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            name = "PopeRigby";
            email = config.privateInfo.poperigby.email;
          };
          aliases = {
            yeet = "!git restore . && git restore --staged . && git clean -df";
            s = "status";
            sw = "switch";
            m = "switch main";
            h = "log --graph --oneline";
          };
          core.autocrlf = "false";
          color.ui = true;
          column.ui = "auto";
          branch.sort = "-committerdate";
          tag.sort = "version:refname";
          init.defaultBranch = "main";
          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          push = {
            default = "simple";
            autoSetupRemote = true;
            followTags = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };
        };
      };
      # Makes diffs easier to read
      difftastic = {
        enable = true;
        git.enable = true;
      };
    };
  };
}
