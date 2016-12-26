# LDAP

DoggoHub integrates with LDAP to support user authentication.
This integration works with most LDAP-compliant directory
servers, including Microsoft Active Directory, Apple Open Directory, Open LDAP,
and 389 Server. DoggoHub EE includes enhanced integration, including group
membership syncing.

## Security

DoggoHub assumes that LDAP users are not able to change their LDAP 'mail', 'email'
or 'userPrincipalName' attribute. An LDAP user who is allowed to change their
email on the LDAP server can potentially
[take over any account](#enabling-ldap-sign-in-for-existing-doggohub-users)
on your DoggoHub server.

We recommend against using LDAP integration if your LDAP users are
allowed to change their 'mail', 'email' or 'userPrincipalName'  attribute on
the LDAP server.

### User deletion

If a user is deleted from the LDAP server, they will be blocked in DoggoHub, as
well. Users will be immediately blocked from logging in. However, there is an
LDAP check cache time (sync time) of one hour (see note). This means users that
are already logged in or are using Git over SSH will still be able to access
DoggoHub for up to one hour. Manually block the user in the DoggoHub Admin area to
immediately block all access.

>**Note**: DoggoHub EE supports a configurable sync time, with a default
of one hour.

## Configuration

To enable LDAP integration you need to add your LDAP server settings in
`/etc/doggohub/doggohub.rb` or `/home/git/doggohub/config/doggohub.yml`.

There is a Rake task to check LDAP configuration. After configuring LDAP
using the documentation below, see [LDAP check Rake task](../raketasks/check.md#ldap-check)
for information on the LDAP check Rake task.

>**Note**: In DoggoHub EE, you can configure multiple LDAP servers to connect to
one DoggoHub server.

Prior to version 7.4, DoggoHub used a different syntax for configuring
LDAP integration. The old LDAP integration syntax still works but may be
removed in a future version. If your `doggohub.rb` or `doggohub.yml` file contains
LDAP settings in both the old syntax and the new syntax, only the __old__
syntax will be used by DoggoHub.

The configuration inside `doggohub_rails['ldap_servers']` below is sensitive to
incorrect indentation. Be sure to retain the indentation given in the example.
Copy/paste can sometimes cause problems.

**Omnibus configuration**

```ruby
doggohub_rails['ldap_enabled'] = true
doggohub_rails['ldap_servers'] = YAML.load <<-EOS # remember to close this block with 'EOS' below
main: # 'main' is the DoggoHub 'provider ID' of this LDAP server
  ## label
  #
  # A human-friendly name for your LDAP server. It is OK to change the label later,
  # for instance if you find out it is too large to fit on the web page.
  #
  # Example: 'Paris' or 'Acme, Ltd.'
  label: 'LDAP'

  host: '_your_ldap_server'
  port: 389
  uid: 'sAMAccountName'
  method: 'plain' # "tls" or "ssl" or "plain"
  bind_dn: '_the_full_dn_of_the_user_you_will_bind_with'
  password: '_the_password_of_the_bind_user'

  # Set a timeout, in seconds, for LDAP queries. This helps avoid blocking
  # a request if the LDAP server becomes unresponsive.
  # A value of 0 means there is no timeout.
  timeout: 10

  # This setting specifies if LDAP server is Active Directory LDAP server.
  # For non AD servers it skips the AD specific queries.
  # If your LDAP server is not AD, set this to false.
  active_directory: true

  # If allow_username_or_email_login is enabled, DoggoHub will ignore everything
  # after the first '@' in the LDAP username submitted by the user on login.
  #
  # Example:
  # - the user enters 'jane.doe@example.com' and 'p@ssw0rd' as LDAP credentials;
  # - DoggoHub queries the LDAP server with 'jane.doe' and 'p@ssw0rd'.
  #
  # If you are using "uid: 'userPrincipalName'" on ActiveDirectory you need to
  # disable this setting, because the userPrincipalName contains an '@'.
  allow_username_or_email_login: false

  # To maintain tight control over the number of active users on your DoggoHub installation,
  # enable this setting to keep new users blocked until they have been cleared by the admin
  # (default: false).
  block_auto_created_users: false

  # Base where we can search for users
  #
  #   Ex. ou=People,dc=doggohub,dc=example
  #
  base: ''

  # Filter LDAP users
  #
  #   Format: RFC 4515 https://tools.ietf.org/search/rfc4515
  #   Ex. (employeeType=developer)
  #
  #   Note: DoggoHub does not support omniauth-ldap's custom filter syntax.
  #
  user_filter: ''

  # LDAP attributes that DoggoHub will use to create an account for the LDAP user.
  # The specified attribute can either be the attribute name as a string (e.g. 'mail'),
  # or an array of attribute names to try in order (e.g. ['mail', 'email']).
  # Note that the user's LDAP login will always be the attribute specified as `uid` above.
  attributes:
    # The username will be used in paths for the user's own projects
    # (like `doggohub.example.com/username/project`) and when mentioning
    # them in issues, merge request and comments (like `@username`).
    # If the attribute specified for `username` contains an email address,
    # the DoggoHub username will be the part of the email address before the '@'.
    username: ['uid', 'userid', 'sAMAccountName']
    email:    ['mail', 'email', 'userPrincipalName']

    # If no full name could be found at the attribute specified for `name`,
    # the full name is determined using the attributes specified for
    # `first_name` and `last_name`.
    name:       'cn'
    first_name: 'givenName'
    last_name:  'sn'

  ## EE only

  # Base where we can search for groups
  #
  #   Ex. ou=groups,dc=doggohub,dc=example
  #
  group_base: ''

  # The CN of a group containing DoggoHub administrators
  #
  #   Ex. administrators
  #
  #   Note: Not `cn=administrators` or the full DN
  #
  admin_group: ''

  # The LDAP attribute containing a user's public SSH key
  #
  #   Ex. ssh_public_key
  #
  sync_ssh_keys: false

# DoggoHub EE only: add more LDAP servers
# Choose an ID made of a-z and 0-9 . This ID will be stored in the database
# so that DoggoHub can remember which LDAP server a user belongs to.
# uswest2:
#   label:
#   host:
#   ....
EOS
```

**Source configuration**

Use the same format as `doggohub_rails['ldap_servers']` for the contents under
`servers:` in the example below:

```
production:
  # snip...
  ldap:
    enabled: false
    servers:
      main: # 'main' is the DoggoHub 'provider ID' of this LDAP server
        ## label
        #
        # A human-friendly name for your LDAP server. It is OK to change the label later,
        # for instance if you find out it is too large to fit on the web page.
        #
        # Example: 'Paris' or 'Acme, Ltd.'
        label: 'LDAP'
        # snip...
```

## Using an LDAP filter to limit access to your DoggoHub server

If you want to limit all DoggoHub access to a subset of the LDAP users on your
LDAP server, the first step should be to narrow the configured `base`. However,
it is sometimes necessary to filter users further. In this case, you can set up
an LDAP user filter. The filter must comply with
[RFC 4515](https://tools.ietf.org/search/rfc4515).

**Omnibus configuration**

```ruby
doggohub_rails['ldap_servers'] = YAML.load <<-EOS
main:
  # snip...
  user_filter: '(employeeType=developer)'
EOS
```

**Source configuration**

```yaml
production:
  ldap:
    servers:
      main:
        # snip...
        user_filter: '(employeeType=developer)'
```

Tip: If you want to limit access to the nested members of an Active Directory
group you can use the following syntax:

```
(memberOf=CN=My Group,DC=Example,DC=com)
```

Please note that DoggoHub does not support the custom filter syntax used by
omniauth-ldap.

## Enabling LDAP sign-in for existing DoggoHub users

When a user signs in to DoggoHub with LDAP for the first time, and their LDAP
email address is the primary email address of an existing DoggoHub user, then
the LDAP DN will be associated with the existing user. If the LDAP email
attribute is not found in DoggoHub's database, a new user is created.

In other words, if an existing DoggoHub user wants to enable LDAP sign-in for
themselves, they should check that their DoggoHub email address matches their
LDAP email address, and then sign into DoggoHub via their LDAP credentials.

## Limitations

### TLS Client Authentication

Not implemented by `Net::LDAP`.
You should disable anonymous LDAP authentication and enable simple or SASL
authentication. The TLS client authentication setting in your LDAP server cannot
be mandatory and clients cannot be authenticated with the TLS protocol.

### TLS Server Authentication

Not supported by DoggoHub's configuration options.
When setting `method: ssl`, the underlying authentication method used by
`omniauth-ldap` is `simple_tls`.  This method establishes TLS encryption with
the LDAP server before any LDAP-protocol data is exchanged but no validation of
the LDAP server's SSL certificate is performed.

## Troubleshooting

### Debug LDAP user filter with ldapsearch

This example uses ldapsearch and assumes you are using ActiveDirectory. The
following query returns the login names of the users that will be allowed to
log in to DoggoHub if you configure your own user_filter.

```
ldapsearch -H ldaps://$host:$port -D "$bind_dn" -y bind_dn_password.txt  -b "$base" "$user_filter" sAMAccountName
```

- Variables beginning with a `$` refer to a variable from the LDAP section of
  your configuration file.
- Replace ldaps:// with ldap:// if you are using the plain authentication method.
  Port `389` is the default `ldap://` port and `636` is the default `ldaps://`
  port.
- We are assuming the password for the bind_dn user is in bind_dn_password.txt.


### Invalid credentials when logging in

- Make sure the user you are binding with has enough permissions to read the user's
tree and traverse it.
- Check that the `user_filter` is not blocking otherwise valid users.
- Run the following check command to make sure that the LDAP settings are
  correct and DoggoHub can see your users:

    ```bash
    # For Omnibus installations
    sudo doggohub-rake doggohub:ldap:check

    # For installations from source
    sudo -u git -H bundle exec rake doggohub:ldap:check RAILS_ENV=production
    ```

### Connection Refused

If you are getting 'Connection Refused' errors when trying to connect to the
LDAP server please double-check the LDAP `port` and `method` settings used by
DoggoHub. Common combinations are `method: 'plain'` and `port: 389`, OR
`method: 'ssl'` and `port: 636`.

### Login with valid credentials rejected

If there is an unexpected error while authenticating the user with the LDAP
backend, the login is rejected and details about the error are logged to
`production.log`.
