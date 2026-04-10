{ den, ... }:
{
  den.aspects.programs.provides.jujutsu.homeManager =
    { pkgs, ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = "PopeRigby";
            email = "poperigby@mailbox.org";
          };
          ui = {
            pager = "delta";
            diff-editor = [ "difft" "--color=always" "$left" "$right" ];
          };
          templates.log = "builtin_log_compact";
          merge-tools.difft = {
            program = "difft";
            diff-args = [
              "--color=always"
              "$left"
              "$right"
            ];
          };
        };
      };

      home.packages = with pkgs; [
        lazyjj
        jjui
      ];
    };
}

