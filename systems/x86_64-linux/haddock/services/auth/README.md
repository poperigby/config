# Authentication

This is my authentication suite.

* [Authelia](https://www.authelia.com/) sits in front of all my exposed services, and provides authentication by hooking into apps with OpenID Connect or just a plain login screen in front of them.
* [LLDAP](https://github.com/lldap/lldap) stores all of my user information, and synchronizes login information to apps that support LDAP but not OpenID Connect.
