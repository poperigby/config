# Defines all hosts, users, and homes
#
# Specific configuration goes in either hosts/ or users/
{
    den.hosts = {
        x86_64-linux = {
            allan = {
                users.cassidy = { };
            };
            calculus = {
                users.shane = { };
            };
            haddock = {
                users = {
                    cassidy = { };
                    julian = { };
                    shane = { };
                };
            };
            snowy = {
                users.cassidy = { };
            };
        };
        x86_64-iso = {
            skut = { };
        };
    };
}
