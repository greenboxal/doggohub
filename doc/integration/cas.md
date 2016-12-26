# CAS OmniAuth Provider

To enable the CAS OmniAuth provider you must register your application with your CAS instance. This requires the service URL DoggoHub will supply to CAS. It should be something like: `https://doggohub.example.com:443/users/auth/cas3/callback?url`. By default handling for SLO is enabled, you only need to configure CAS for backchannel logout.

1.  On your DoggoHub server, open the configuration file.

    For omnibus package:

    ```sh
      sudo editor /etc/doggohub/doggohub.rb
    ```

    For installations from source:

    ```sh
      cd /home/git/doggohub

      sudo -u git -H editor config/doggohub.yml
    ```

1.  See [Initial OmniAuth Configuration](omniauth.md#initial-omniauth-configuration) for initial settings.

1.  Add the provider configuration:

    For omnibus package:

    ```ruby
      doggohub_rails['omniauth_providers'] = [
        {
            "name"=> "cas3",
            "label"=> "cas",
            "args"=> {
                "url"=> 'CAS_SERVER',
                "login_url"=> '/CAS_PATH/login',
                "service_validate_url"=> '/CAS_PATH/p3/serviceValidate',
                "logout_url"=> '/CAS_PATH/logout'
            }
        }
      ]
    ```
    

    For installations from source:

    ```
      - { name: 'cas3',
          label: 'cas',
          args: {
                  url: 'CAS_SERVER',
                  login_url: '/CAS_PATH/login',
                  service_validate_url: '/CAS_PATH/p3/serviceValidate',
                  logout_url: '/CAS_PATH/logout'} }
    ```

1.  Change 'CAS_PATH' to the root of your CAS instance (ie. `cas`).

1.  If your CAS instance does not use default TGC lifetimes, update the `cas3.session_duration` to at least the current TGC maximum lifetime. To explicitly disable SLO, regardless of CAS settings, set this to 0.

1.  Save the configuration file.

1.  Run `doggohub-ctl reconfigure` for the omnibus package.

1.  Restart DoggoHub for the changes to take effect.

On the sign in page there should now be a CAS tab in the sign in form.
