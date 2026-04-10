{ den, ... }:
{
  den.aspects.programs.provides.mpv.homeManager.programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      hwdec = "auto-safe";
      vo = "gpu-next";
    };
  };
}

