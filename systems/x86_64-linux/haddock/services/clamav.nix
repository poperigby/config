{ ... }:

{
  services.clamav = {
    daemon.enable = true;
    scanner = {
      enable = true;
      scanDirectories = [
        "/etc"
        "/home"
        "/mnt/media/data/torrents"
        "/tmp"
        "/var/lib"
        "/var/tmp"
      ];
    };

    ## Signature updaters
    # Third party
    fangfrisch.enable = true;
    # Official
    updater.enable = true;
  };
}
