{ ... }:

{
  services.octoprint = {
    enable = true;
    plugins =
      plugins: with plugins; [
        # Show IP address on Prusa screen
        ipOnConnect
      ];
    extraConfig = {
      # Allow communicating with printer over serial connection
      # https://help.prusa3d.com/article/octoprint-configuration-and-install_2182#configure-rpi-zero-w-gpio
      serial = {
        additionalPorts = [ "/dev/ttyAMA0" ];
        autoconnect = true;
        baudrate = 115200;
        port = "/dev/ttyAMA0";
      };
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      octoprint = super.octoprint.override {
        packageOverrides = pyself: pysuper: {
          ipOnConnect = pyself.buildPythonPackage rec {
            pname = "PrettyGCode";
            version = "0.2.4";
            src = self.fetchFromGitHub {
              owner = "jneilliii";
              repo = "OctoPrint-ipOnConnect";
              tag = version;
              hash = "sha256-tAEnGC11rHWa2hoW+ZLhjqY21WPOgdvuXejGJ4uqkuE=";
            };
            propagatedBuildInputs = [ pysuper.octoprint ];
          };
        };
      };
    })
  ];
}
