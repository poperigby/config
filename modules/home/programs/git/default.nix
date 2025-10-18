{ config, lib, ... }:

let
  cfg = config.custom.programs.git;
in
{
  options.custom.programs.git.enable = lib.mkEnableOption "Enable git";

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "PopeRigby";
      userEmail = config.privateInfo.poperigby.email;
      lfs.enable = true;
      # Makes diffs easier to read
      difftastic.enable = true;
      aliases = {
        yeet = "!git restore . && git restore --staged . && git clean -df";
        s = "status";
        sw = "switch";
        m = "switch main";
        h = "log --graph --oneline";
      };
      extraConfig = {
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
  };
}
