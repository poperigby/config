{ ... }:

{
  custom = {
    suites = {
      common.enable = true;
      gaming.enable = true;
      gui.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
