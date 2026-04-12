{ ... }:
{
    den.aspects.programs.provides.gpg.homeManager = {
        programs.gpg.enable = true;
        services.gpg-agent = {
            enable = true;
            enableSshSupport = true;
            defaultCacheTtl = 60 * 60 * 8;
            maxCacheTtl = 60 * 60 * 8;
        };
    };
}
