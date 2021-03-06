# Shibboleth OmniAuth Provider

This documentation is for enabling shibboleth with omnibus-doggohub package.

In order to enable Shibboleth support in doggohub we need to use Apache instead of Nginx (It may be possible to use Nginx, however this is difficult to configure using the bundled Nginx provided in the omnibus-doggohub package). Apache uses mod_shib2 module for shibboleth authentication and can pass attributes as headers to omniauth-shibboleth provider.


To enable the Shibboleth OmniAuth provider you must:

1. Configure Apache shibboleth module. Installation and configuration of module it self is out of scope of this document.
Check https://wiki.shibboleth.net/ for more info.

1. You can find Apache config in doggohub-recipes (https://doggohub.com/doggohub-org/doggohub-recipes/tree/master/web-server/apache)

Following changes are needed to enable shibboleth:

protect omniauth-shibboleth callback URL:
```
  <Location /users/auth/shibboleth/callback>
    AuthType shibboleth
    ShibRequestSetting requireSession 1
    ShibUseHeaders On
    require valid-user
  </Location>

  Alias /shibboleth-sp /usr/share/shibboleth
  <Location /shibboleth-sp>
    Satisfy any
  </Location>

  <Location /Shibboleth.sso>
    SetHandler shib
  </Location>
```
exclude shibboleth URLs from rewriting, add "RewriteCond %{REQUEST_URI} !/Shibboleth.sso" and "RewriteCond %{REQUEST_URI} !/shibboleth-sp", config should look like this:
```
  # Apache equivalent of Nginx try files
  RewriteEngine on
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_URI} !/Shibboleth.sso
  RewriteCond %{REQUEST_URI} !/shibboleth-sp
  RewriteRule .* http://127.0.0.1:8080%{REQUEST_URI} [P,QSA]
  RequestHeader set X_FORWARDED_PROTO 'https'
```

1.  Edit /etc/doggohub/doggohub.rb configuration file, your shibboleth attributes should be in form of "HTTP_ATTRIBUTE" and you should addjust them to your need and environment. Add any other configuration you need.

File should look like this:
```
external_url 'https://doggohub.example.com'
doggohub_rails['internal_api_url'] = 'https://doggohub.example.com'

# disable Nginx
nginx['enable'] = false

doggohub_rails['omniauth_allow_single_sign_on'] = true
doggohub_rails['omniauth_block_auto_created_users'] = false
doggohub_rails['omniauth_enabled'] = true
doggohub_rails['omniauth_providers'] = [
  {
    "name" => 'shibboleth',
        "args" => {
        "shib_session_id_field" => "HTTP_SHIB_SESSION_ID",
        "shib_application_id_field" => "HTTP_SHIB_APPLICATION_ID",
        "uid_field" => 'HTTP_EPPN',
        "name_field" => 'HTTP_CN',
        "info_fields" => { "email" => 'HTTP_MAIL'}
        }
  }
]

```
1. Save changes and reconfigure doggohub:
```
sudo doggohub-ctl reconfigure
```

On the sign in page there should now be a "Sign in with: Shibboleth" icon below the regular sign in form. Click the icon to begin the authentication process. You will be redirected to IdP server (Depends on your Shibboleth module configuration). If everything goes well the user will be returned to DoggoHub and will be signed in.

## Apache 2.4 / DoggoHub 8.6 update
The order of the first 2 Location directives is important. If they are reversed,
you will not get a shibboleth session!

```
  <Location />
    Require all granted
    ProxyPassReverse http://127.0.0.1:8181
    ProxyPassReverse http://YOUR_SERVER_FQDN/
  </Location>

  <Location /users/auth/shibboleth/callback>
    AuthType shibboleth
    ShibRequestSetting requireSession 1
    ShibUseHeaders On
    Require shib-session
  </Location>

  Alias /shibboleth-sp /usr/share/shibboleth

  <Location /shibboleth-sp>
    Require all granted
  </Location>

  <Location /Shibboleth.sso>
    SetHandler shib
  </Location>

  RewriteEngine on

  #Don't escape encoded characters in api requests
  RewriteCond %{REQUEST_URI} ^/api/v3/.*
  RewriteCond %{REQUEST_URI} !/Shibboleth.sso
  RewriteCond %{REQUEST_URI} !/shibboleth-sp
  RewriteRule .* http://127.0.0.1:8181%{REQUEST_URI} [P,QSA,NE]

  #Forward all requests to doggohub-workhorse except existing files
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f [OR]
  RewriteCond %{REQUEST_URI} ^/uploads/.*
  RewriteCond %{REQUEST_URI} !/Shibboleth.sso
  RewriteCond %{REQUEST_URI} !/shibboleth-sp
  RewriteRule .* http://127.0.0.1:8181%{REQUEST_URI} [P,QSA]

  RequestHeader set X_FORWARDED_PROTO 'https'
  RequestHeader set X-Forwarded-Ssl on
```