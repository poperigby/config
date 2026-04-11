# Authentication

This is my authentication suite.

* [Authelia](https://www.authelia.com/) sits in front of all my exposed services, and provides authentication by hooking into apps with OpenID Connect or just a plain login screen in front of them.
* [LLDAP](https://github.com/lldap/lldap) stores all of my user information, and synchronizes login information to apps that support LDAP but not OpenID Connect.

## LLDAP Users

* `authelia` is in the `lldap_password_manager` group, and is used for looking up and changing LLDAP passwords through Authelia

## Adding Clients

1. Generate a client ID if the client is private

```bash
nix run nixpkgs#authelia -- crypto rand --length 72 --charset rfc3986
```

2. Generate a hashed and unhashed client secret with the following command:

```bash
nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
```

3. Open `secrets.yaml` and add the generated values in the following way:

```yaml
haddock:
    <application_name>:
        oidc_client_id: <client_id>
        oidc_client_secret:
            <application_name>: <unhashed_secret>
            authelia: <hashed_secret>
```

4. Use the unhashed secret in the application's configuration, and the hashed one in Authelia's configuration.
