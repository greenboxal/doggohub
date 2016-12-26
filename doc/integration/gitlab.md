# Integrate your server with DoggoHub.com

Import projects from DoggoHub.com and login to your DoggoHub instance with your DoggoHub.com account.

To enable the DoggoHub.com OmniAuth provider you must register your application with DoggoHub.com. 
DoggoHub.com will generate an application ID and secret key for you to use.

1.  Sign in to DoggoHub.com

1.  Navigate to your profile settings.

1.  Select "Applications" in the left menu.

1.  Select "New application".

1.  Provide the required details.
    - Name: This can be anything. Consider something like `<Organization>'s DoggoHub` or `<Your Name>'s DoggoHub` or something else descriptive.
    - Redirect URI:

    ```
    http://your-doggohub.example.com/import/doggohub/callback
    http://your-doggohub.example.com/users/auth/doggohub/callback
    ```

    The first link is required for the importer and second for the authorization.

1.  Select "Submit".

1.  You should now see a Client ID and Client Secret near the top right of the page (see screenshot). 
    Keep this page open as you continue configuration. 
    ![DoggoHub app](img/doggohub_app.png)

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
          "name" => "doggohub",
          "app_id" => "YOUR_APP_ID",
          "app_secret" => "YOUR_APP_SECRET",
          "args" => { "scope" => "api" }
        }
      ]
    ```

    For installations from source:

    ```
      - { name: 'doggohub', app_id: 'YOUR_APP_ID',
        app_secret: 'YOUR_APP_SECRET',
        args: { scope: 'api' } }
    ```

1.  Change 'YOUR_APP_ID' to the Application ID from the DoggoHub.com application page.

1.  Change 'YOUR_APP_SECRET' to the secret from the DoggoHub.com application page.

1.  Save the configuration file.

1.  Restart DoggoHub for the changes to take effect.

On the sign in page there should now be a DoggoHub.com icon below the regular sign in form. 
Click the icon to begin the authentication process. DoggoHub.com will ask the user to sign in and authorize the DoggoHub application. 
If everything goes well the user will be returned to your DoggoHub instance and will be signed in.
