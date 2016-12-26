# Integrate your DoggoHub server with Bitbucket

Import projects from Bitbucket.org and login to your DoggoHub instance with your
Bitbucket.org account.

## Overview

You can set up Bitbucket.org as an OAuth2 provider so that you can use your
credentials to authenticate into DoggoHub or import your projects from
Bitbucket.org.

- To use Bitbucket.org as an OmniAuth provider, follow the [Bitbucket OmniAuth
  provider](#bitbucket-omniauth-provider) section.
- To import projects from Bitbucket, follow both the
  [Bitbucket OmniAuth provider](#bitbucket-omniauth-provider) and
  [Bitbucket project import](#bitbucket-project-import) sections.

## Bitbucket OmniAuth provider

> **Note:**
DoggoHub 8.15 significantly simplified the way to integrate Bitbucket.org with
DoggoHub. You are encouraged to upgrade your DoggoHub instance if you haven't done
already. If you're using DoggoHub 8.14 and below, [use the previous integration
docs][bb-old].

To enable the Bitbucket OmniAuth provider you must register your application
with Bitbucket.org. Bitbucket will generate an application ID and secret key for
you to use.

1.  Sign in to [Bitbucket.org](https://bitbucket.org).
1.  Navigate to your individual user settings (**Bitbucket settings**) or a team's
    settings (**Manage team**), depending on how you want the application registered.
    It does not matter if the application is registered as an individual or a
    team, that is entirely up to you.
1.  Select **OAuth** in the left menu under "Access Management".
1.  Select **Add consumer**.
1.  Provide the required details:

    | Item | Description |
    | :--- | :---------- |
    | **Name** | This can be anything. Consider something like `<Organization>'s DoggoHub` or `<Your Name>'s DoggoHub` or something else descriptive. |
    | **Application description** | Fill this in if you wish. |
    | **Callback URL** | The URL to your DoggoHub installation, e.g., `https://doggohub.example.com`. |
    | **URL** | The URL to your DoggoHub installation, e.g., `https://doggohub.example.com`. |

    NOTE: Starting in DoggoHub 8.15, you MUST specify a callback URL, or you will
    see an "Invalid redirect_uri" message. For more details, see [the
    Bitbucket documentation](https://confluence.atlassian.com/bitbucket/oauth-faq-338365710.html).

    And grant at least the following permissions:

    ```
    Account: Email, Read
    Repositories: Read
    Pull Requests: Read
    Issues: Read
    Wiki: Read and Write
    ```

    ![Bitbucket OAuth settings page](img/bitbucket_oauth_settings_page.png)

1.  Select **Save**.
1.  Select your newly created OAuth consumer and you should now see a Key and
    Secret in the list of OAuth customers. Keep this page open as you continue
    the configuration.

      ![Bitbucket OAuth key](img/bitbucket_oauth_keys.png)

1.  On your DoggoHub server, open the configuration file:

    ```
    # For Omnibus packages
    sudo editor /etc/doggohub/doggohub.rb

    # For installations from source
    sudo -u git -H editor /home/git/doggohub/config/doggohub.yml
    ```

1.  Follow the [Initial OmniAuth Configuration](omniauth.md#initial-omniauth-configuration)
    for initial settings.
1.  Add the Bitbucket provider configuration:

    For Omnibus packages:

    ```ruby
    doggohub_rails['omniauth_providers'] = [
      {
        "name" => "bitbucket",
        "app_id" => "BITBUCKET_APP_KEY",
        "app_secret" => "BITBUCKET_APP_SECRET",
        "url" => "https://bitbucket.org/"
      }
    ]
    ```

    For installations from source:

    ```yaml
    - { name: 'bitbucket',
        app_id: 'BITBUCKET_APP_KEY',
        app_secret: 'BITBUCKET_APP_SECRET',
        url: 'https://bitbucket.org/' }
    ```

    ---

    Where `BITBUCKET_APP_KEY` is the Key and `BITBUCKET_APP_SECRET` the Secret
    from the Bitbucket application page.

1.  Save the configuration file.
1.  [Reconfigure][] or [restart DoggoHub][] for the changes to take effect if you
    installed DoggoHub via Omnibus or from source respectively.

On the sign in page there should now be a Bitbucket icon below the regular sign
in form. Click the icon to begin the authentication process. Bitbucket will ask
the user to sign in and authorize the DoggoHub application. If everything goes
well, the user will be returned to DoggoHub and will be signed in.

## Bitbucket project import

Once the above configuration is set up, you can use Bitbucket to sign into
DoggoHub and [start importing your projects][bb-import].

[init-oauth]: omniauth.md#initial-omniauth-configuration
[bb-import]: ../workflow/importing/import_projects_from_bitbucket.md
[bb-old]: https://doggohub.com/doggohub-org/doggohub-ce/blob/8-14-stable/doc/integration/bitbucket.md
[bitbucket-docs]: https://confluence.atlassian.com/bitbucket/use-the-ssh-protocol-with-bitbucket-cloud-221449711.html#UsetheSSHprotocolwithBitbucketCloud-KnownhostorBitbucket%27spublickeyfingerprints
[reconfigure]: ../administration/restart_doggohub.md#omnibus-doggohub-reconfigure
[restart DoggoHub]: ../administration/restart_doggohub.md#installations-from-source
