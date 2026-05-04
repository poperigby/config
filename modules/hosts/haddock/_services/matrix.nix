{ ... }:

{
    services = {
        matrix-continuwuity = {
            enable = true;
            settings = {
                global = {
                    server_name = "haddock.cc";
                    new_user_displayname_suffix = "";
                };
            };

        };
        caddy.virtualHosts = {
            "haddock.cc".extraConfig = # caddy
                ''
                    # Federation well-known
                    header /.well-known/matrix/server Content-Type application/json
                    respond /.well-known/matrix/server `{ "m.server": "matrix.haddock.cc:443" }` 200

                    # Client well-known — CORS required
                    header /.well-known/matrix/client Content-Type application/json
                    header /.well-known/matrix/client Access-Control-Allow-Origin *
                    respond /.well-known/matrix/client `{ "m.homeserver": { "base_url": "https://matrix.haddock.cc" }}` 200
                '';
            "matrix.haddock.cc".extraConfig = ''
                reverse_proxy :6167
            '';
        };
    };
}
