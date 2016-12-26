# Installation from source

## Consider the Omnibus package installation

Since an installation from source is a lot of work and error prone we strongly recommend the fast and reliable [Omnibus package installation](https://about.doggohub.com/downloads/) (deb/rpm).

One reason the Omnibus package is more reliable is its use of Runit to restart any of the DoggoHub processes in case one crashes.
On heavily used DoggoHub instances the memory usage of the Sidekiq background worker will grow over time.
Omnibus packages solve this by [letting the Sidekiq terminate gracefully](http://docs.doggohub.com/ce/operations/sidekiq_memory_killer.html) if it uses too much memory.
After this termination Runit will detect Sidekiq is not running and will start it.
Since installations from source don't have Runit, Sidekiq can't be terminated and its memory usage will grow over time.

## Select Version to Install

Make sure you view [this installation guide](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/install/installation.md) from the tag (version) of DoggoHub you would like to install.
In most cases this should be the highest numbered production tag (without rc in it).
You can select the tag in the version dropdown in the top left corner of DoggoHub (below the menu bar).

If the highest number stable branch is unclear please check the [DoggoHub Blog](https://about.doggohub.com/blog/) for installation guide links by version.

## Important Notes

This guide is long because it covers many cases and includes all commands you need, this is [one of the few installation scripts that actually works out of the box](https://twitter.com/robinvdvleuten/status/424163226532986880).

This installation guide was created for and tested on **Debian/Ubuntu** operating systems. Please read [requirements.md](requirements.md) for hardware and operating system requirements. If you want to install on RHEL/CentOS we recommend using the [Omnibus packages](https://about.doggohub.com/downloads/).

This is the official installation guide to set up a production server. To set up a **development installation** or for many other installation options please see [the installation section of the readme](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/README.md#installation).

The following steps have been known to work. Please **use caution when you deviate** from this guide. Make sure you don't violate any assumptions DoggoHub makes about its environment. For example many people run into permission problems because they changed the location of directories or run services as the wrong user.

If you find a bug/error in this guide please **submit a merge request**
following the
[contributing guide](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/CONTRIBUTING.md).

## Overview

The DoggoHub installation consists of setting up the following components:

1. Packages / Dependencies
1. Ruby
1. Go
1. System Users
1. Database
1. Redis
1. DoggoHub
1. Nginx

## 1. Packages / Dependencies

`sudo` is not installed on Debian by default. Make sure your system is
up-to-date and install it.

    # run as root!
    apt-get update -y
    apt-get upgrade -y
    apt-get install sudo -y

**Note:** During this installation some files will need to be edited manually. If you are familiar with vim set it as default editor with the commands below. If you are not familiar with vim please skip this and keep using the default editor.

    # Install vim and set as default editor
    sudo apt-get install -y vim
    sudo update-alternatives --set editor /usr/bin/vim.basic

Install the required packages (needed to compile Ruby and native extensions to Ruby gems):

    sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate python-docutils pkg-config cmake nodejs

If you want to use Kerberos for user authentication, then install libkrb5-dev:

    sudo apt-get install libkrb5-dev

**Note:** If you don't know what Kerberos is, you can assume you don't need it.

Make sure you have the right version of Git installed

    # Install Git
    sudo apt-get install -y git-core

    # Make sure Git is version 2.8.4 or higher
    git --version

Is the system packaged Git too old? Remove it and compile from source.

    # Remove packaged Git
    sudo apt-get remove git-core

    # Install dependencies
    sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential

    # Download and compile from source
    cd /tmp
    curl --remote-name --progress https://www.kernel.org/pub/software/scm/git/git-2.8.4.tar.gz
    echo '626e319f8a24fc0866167ea5f6bf3e2f38f69d6cb2e59e150f13709ca3ebf301  git-2.8.4.tar.gz' | shasum -a256 -c - && tar -xzf git-2.8.4.tar.gz
    cd git-2.8.4/
    ./configure
    make prefix=/usr/local all

    # Install into /usr/local/bin
    sudo make prefix=/usr/local install

    # When editing config/doggohub.yml (Step 5), change the git -> bin_path to /usr/local/bin/git

**Note:** In order to receive mail notifications, make sure to install a mail server. By default, Debian is shipped with exim4 but this [has problems](https://github.com/doggohubhq/doggohubhq/issues/4866#issuecomment-32726573) while Ubuntu does not ship with one. The recommended mail server is postfix and you can install it with:

    sudo apt-get install -y postfix

Then select 'Internet Site' and press enter to confirm the hostname.

## 2. Ruby

**Note:** The current supported Ruby versions are 2.1.x and 2.3.x. 2.3.x is preferred, and support for 2.1.x will be dropped in the future.

The use of Ruby version managers such as [RVM], [rbenv] or [chruby] with DoggoHub
in production, frequently leads to hard to diagnose problems. For example,
DoggoHub Shell is called from OpenSSH, and having a version manager can prevent
pushing and pulling over SSH. Version managers are not supported and we strongly
advise everyone to follow the instructions below to use a system Ruby.

Remove the old Ruby 1.8 if present:

    sudo apt-get remove ruby1.8

Download Ruby and compile it:

    mkdir /tmp/ruby && cd /tmp/ruby
    curl --remote-name --progress https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.3.tar.gz
    echo 'a8db9ce7f9110320f33b8325200e3ecfbd2b534b ruby-2.3.3.tar.gz' | shasum -c - && tar xzf ruby-2.3.3.tar.gz
    cd ruby-2.3.3
    ./configure --disable-install-rdoc
    make
    sudo make install

Install the Bundler Gem:

    sudo gem install bundler --no-ri --no-rdoc

## 3. Go

Since DoggoHub 8.0, Git HTTP requests are handled by doggohub-workhorse (formerly
doggohub-git-http-server). This is a small daemon written in Go. To install
doggohub-workhorse we need a Go compiler. The instructions below assume you
use 64-bit Linux. You can find downloads for other platforms at the [Go download
page](https://golang.org/dl).

    # Remove former Go installation folder
    sudo rm -rf /usr/local/go

    curl --remote-name --progress https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz
    echo '43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53  go1.5.3.linux-amd64.tar.gz' | shasum -a256 -c - && \
      sudo tar -C /usr/local -xzf go1.5.3.linux-amd64.tar.gz
    sudo ln -sf /usr/local/go/bin/{go,godoc,gofmt} /usr/local/bin/
    rm go1.5.3.linux-amd64.tar.gz

## 4. System Users

Create a `git` user for DoggoHub:

    sudo adduser --disabled-login --gecos 'DoggoHub' git

## 5. Database

We recommend using a PostgreSQL database. For MySQL check the
[MySQL setup guide](database_mysql.md).

> **Note**: because we need to make use of extensions you need at least pgsql 9.1.

1. Install the database packages:

    ```bash
    sudo apt-get install -y postgresql postgresql-client libpq-dev postgresql-contrib
    ```

1. Create a database user for DoggoHub:

    ```bash
    sudo -u postgres psql -d template1 -c "CREATE USER git CREATEDB;"
    ```

1. Create the `pg_trgm` extension (required for DoggoHub 8.6+):

    ```bash
    sudo -u postgres psql -d template1 -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    ```

1. Create the DoggoHub production database and grant all privileges on database:

    ```bash
    sudo -u postgres psql -d template1 -c "CREATE DATABASE doggohubhq_production OWNER git;"
    ```

1. Try connecting to the new database with the new user:

    ```bash
    sudo -u git -H psql -d doggohubhq_production
    ```

1. Check if the `pg_trgm` extension is enabled:

    ```bash
    SELECT true AS enabled
    FROM pg_available_extensions
    WHERE name = 'pg_trgm'
    AND installed_version IS NOT NULL;
    ```

    If the extension is enabled this will produce the following output:

    ```
    enabled
    ---------
     t
    (1 row)
    ```

1. Quit the database session:

    ```bash
    doggohubhq_production> \q
    ```

## 6. Redis

DoggoHub requires at least Redis 2.8.

If you are using Debian 8 or Ubuntu 14.04 and up, then you can simply install
Redis 2.8 with:

```sh
sudo apt-get install redis-server
```

If you are using Debian 7 or Ubuntu 12.04, follow the special documentation
on [an alternate Redis installation](redis.md). Once done, follow the rest of
the guide here.

```
# Configure redis to use sockets
sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.orig

# Disable Redis listening on TCP by setting 'port' to 0
sed 's/^port .*/port 0/' /etc/redis/redis.conf.orig | sudo tee /etc/redis/redis.conf

# Enable Redis socket for default Debian / Ubuntu path
echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a /etc/redis/redis.conf

# Grant permission to the socket to all members of the redis group
echo 'unixsocketperm 770' | sudo tee -a /etc/redis/redis.conf

# Create the directory which contains the socket
mkdir /var/run/redis
chown redis:redis /var/run/redis
chmod 755 /var/run/redis

# Persist the directory which contains the socket, if applicable
if [ -d /etc/tmpfiles.d ]; then
  echo 'd  /var/run/redis  0755  redis  redis  10d  -' | sudo tee -a /etc/tmpfiles.d/redis.conf
fi

# Activate the changes to redis.conf
sudo service redis-server restart

# Add git to the redis group
sudo usermod -aG redis git
```

## 7. DoggoHub

    # We'll install DoggoHub into home directory of the user "git"
    cd /home/git

### Clone the Source

    # Clone DoggoHub repository
    sudo -u git -H git clone https://doggohub.com/doggohub-org/doggohub-ce.git -b 8-15-stable doggohub

**Note:** You can change `8-15-stable` to `master` if you want the *bleeding edge* version, but never install master on a production server!

### Configure It

    # Go to DoggoHub installation folder
    cd /home/git/doggohub

    # Copy the example DoggoHub config
    sudo -u git -H cp config/doggohub.yml.example config/doggohub.yml

    # Update DoggoHub config file, follow the directions at top of file
    sudo -u git -H editor config/doggohub.yml

    # Copy the example secrets file
    sudo -u git -H cp config/secrets.yml.example config/secrets.yml
    sudo -u git -H chmod 0600 config/secrets.yml

    # Make sure DoggoHub can write to the log/ and tmp/ directories
    sudo chown -R git log/
    sudo chown -R git tmp/
    sudo chmod -R u+rwX,go-w log/
    sudo chmod -R u+rwX tmp/

    # Make sure DoggoHub can write to the tmp/pids/ and tmp/sockets/ directories
    sudo chmod -R u+rwX tmp/pids/
    sudo chmod -R u+rwX tmp/sockets/

    # Create the public/uploads/ directory
    sudo -u git -H mkdir public/uploads/

    # Make sure only the DoggoHub user has access to the public/uploads/ directory
    # now that files in public/uploads are served by doggohub-workhorse
    sudo chmod 0700 public/uploads

    # Change the permissions of the directory where CI build traces are stored
    sudo chmod -R u+rwX builds/

    # Change the permissions of the directory where CI artifacts are stored
    sudo chmod -R u+rwX shared/artifacts/

    # Copy the example Unicorn config
    sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb

    # Find number of cores
    nproc

    # Enable cluster mode if you expect to have a high load instance
    # Set the number of workers to at least the number of cores
    # Ex. change amount of workers to 3 for 2GB RAM server
    sudo -u git -H editor config/unicorn.rb

    # Copy the example Rack attack config
    sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

    # Configure Git global settings for git user
    # 'autocrlf' is needed for the web editor
    sudo -u git -H git config --global core.autocrlf input

    # Disable 'git gc --auto' because DoggoHub already runs 'git gc' when needed
    sudo -u git -H git config --global gc.auto 0

    # Enable packfile bitmaps
    sudo -u git -H git config --global repack.writeBitmaps true

    # Configure Redis connection settings
    sudo -u git -H cp config/resque.yml.example config/resque.yml

    # Change the Redis socket path if you are not using the default Debian / Ubuntu configuration
    sudo -u git -H editor config/resque.yml

**Important Note:** Make sure to edit both `doggohub.yml` and `unicorn.rb` to match your setup.

**Note:** If you want to use HTTPS, see [Using HTTPS](#using-https) for the additional steps.

### Configure DoggoHub DB Settings

    # PostgreSQL only:
    sudo -u git cp config/database.yml.postgresql config/database.yml

    # MySQL only:
    sudo -u git cp config/database.yml.mysql config/database.yml

    # MySQL and remote PostgreSQL only:
    # Update username/password in config/database.yml.
    # You only need to adapt the production settings (first part).
    # If you followed the database guide then please do as follows:
    # Change 'secure password' with the value you have given to $password
    # You can keep the double quotes around the password
    sudo -u git -H editor config/database.yml

    # PostgreSQL and MySQL:
    # Make config/database.yml readable to git only
    sudo -u git -H chmod o-rwx config/database.yml

### Install Gems

**Note:** As of bundler 1.5.2, you can invoke `bundle install -jN` (where `N` the number of your processor cores) and enjoy the parallel gems installation with measurable difference in completion time (~60% faster). Check the number of your cores with `nproc`. For more information check this [post](https://robots.thoughtbot.com/parallel-gem-installing-using-bundler). First make sure you have bundler >= 1.5.2 (run `bundle -v`) as it addresses some [issues](https://devcenter.heroku.com/changelog-items/411) that were [fixed](https://github.com/bundler/bundler/pull/2817) in 1.5.2.

    # For PostgreSQL (note, the option says "without ... mysql")
    sudo -u git -H bundle install --deployment --without development test mysql aws kerberos

    # Or if you use MySQL (note, the option says "without ... postgres")
    sudo -u git -H bundle install --deployment --without development test postgres aws kerberos

**Note:** If you want to use Kerberos for user authentication, then omit `kerberos` in the `--without` option above.

### Install DoggoHub Shell

DoggoHub Shell is an SSH access and repository management software developed specially for DoggoHub.

    # Run the installation task for doggohub-shell (replace `REDIS_URL` if needed):
    sudo -u git -H bundle exec rake doggohub:shell:install REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production SKIP_STORAGE_VALIDATION=true

    # By default, the doggohub-shell config is generated from your main DoggoHub config.
    # You can review (and modify) the doggohub-shell config as follows:
    sudo -u git -H editor /home/git/doggohub-shell/config.yml

**Note:** If you want to use HTTPS, see [Using HTTPS](#using-https) for the additional steps.

**Note:** Make sure your hostname can be resolved on the machine itself by either a proper DNS record or an additional line in /etc/hosts ("127.0.0.1  hostname"). This might be necessary for example if you set up DoggoHub behind a reverse proxy. If the hostname cannot be resolved, the final installation check will fail with "Check DoggoHub API access: FAILED. code: 401" and pushing commits will be rejected with "[remote rejected] master -> master (hook declined)".

### Install doggohub-workhorse

DoggoHub-Workhorse uses [GNU Make](https://www.gnu.org/software/make/). The
following command-line will install DoggoHub-Workhorse in `/home/git/doggohub-workhorse`
which is the recommended location.

    cd /home/git/doggohub

    sudo -u git -H bundle exec rake "doggohub:workhorse:install[/home/git/doggohub-workhorse]" RAILS_ENV=production

### Initialize Database and Activate Advanced Features

    # Go to DoggoHub installation folder

    cd /home/git/doggohub

    sudo -u git -H bundle exec rake doggohub:setup RAILS_ENV=production

    # Type 'yes' to create the database tables.

    # When done you see 'Administrator account created:'

**Note:** You can set the Administrator/root password and e-mail by supplying them in environmental variables, `DOGGOHUB_ROOT_PASSWORD` and `DOGGOHUB_ROOT_EMAIL` respectively, as seen below. If you don't set the password (and it is set to the default one) please wait with exposing DoggoHub to the public internet until the installation is done and you've logged into the server the first time. During the first login you'll be forced to change the default password.

    sudo -u git -H bundle exec rake doggohub:setup RAILS_ENV=production DOGGOHUB_ROOT_PASSWORD=yourpassword DOGGOHUB_ROOT_EMAIL=youremail

### Secure secrets.yml

The `secrets.yml` file stores encryption keys for sessions and secure variables.
Backup `secrets.yml` someplace safe, but don't store it in the same place as your database backups.
Otherwise your secrets are exposed if one of your backups is compromised.

### Install Init Script

Download the init script (will be `/etc/init.d/doggohub`):

    sudo cp lib/support/init.d/doggohub /etc/init.d/doggohub

And if you are installing with a non-default folder or user copy and edit the defaults file:

    sudo cp lib/support/init.d/doggohub.default.example /etc/default/doggohub

If you installed DoggoHub in another directory or as a user other than the default you should change these settings in `/etc/default/doggohub`. Do not edit `/etc/init.d/doggohub` as it will be changed on upgrade.

Make DoggoHub start on boot:

    sudo update-rc.d doggohub defaults 21

### Setup Logrotate

    sudo cp lib/support/logrotate/doggohub /etc/logrotate.d/doggohub

### Check Application Status

Check if DoggoHub and its environment are configured correctly:

    sudo -u git -H bundle exec rake doggohub:env:info RAILS_ENV=production

### Compile Assets

    sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production

### Start Your DoggoHub Instance

    sudo service doggohub start
    # or
    sudo /etc/init.d/doggohub restart

## 8. Nginx

**Note:** Nginx is the officially supported web server for DoggoHub. If you cannot or do not want to use Nginx as your web server, have a look at the [DoggoHub recipes](https://doggohub.com/doggohub-org/doggohub-recipes/).

### Installation

    sudo apt-get install -y nginx

### Site Configuration

Copy the example site config:

    sudo cp lib/support/nginx/doggohub /etc/nginx/sites-available/doggohub
    sudo ln -s /etc/nginx/sites-available/doggohub /etc/nginx/sites-enabled/doggohub

Make sure to edit the config file to match your setup. Also, ensure that you match your paths to DoggoHub, especially if installing for a user other than the 'git' user:

    # Change YOUR_SERVER_FQDN to the fully-qualified
    # domain name of your host serving DoggoHub.
    #
    # Remember to match your paths to DoggoHub, especially
    # if installing for a user other than 'git'.
    #
    # If using Ubuntu default nginx install:
    # either remove the default_server from the listen line
    # or else sudo rm -f /etc/nginx/sites-enabled/default
    sudo editor /etc/nginx/sites-available/doggohub

**Note:** If you want to use HTTPS, replace the `doggohub` Nginx config with `doggohub-ssl`. See [Using HTTPS](#using-https) for HTTPS configuration details.

### Test Configuration

Validate your `doggohub` or `doggohub-ssl` Nginx config file with the following command:

    sudo nginx -t

You should receive `syntax is okay` and `test is successful` messages. If you receive errors check your `doggohub` or `doggohub-ssl` Nginx config file for typos, etc. as indicated in the error message given.

### Restart

    sudo service nginx restart

## Done!

### Double-check Application Status

To make sure you didn't miss anything run a more thorough check with:

    sudo -u git -H bundle exec rake doggohub:check RAILS_ENV=production

If all items are green, then congratulations on successfully installing DoggoHub!

NOTE: Supply `SANITIZE=true` environment variable to `doggohub:check` to omit project names from the output of the check command.

### Initial Login

Visit YOUR_SERVER in your web browser for your first DoggoHub login.

If you didn't [provide a root password during setup](#initialize-database-and-activate-advanced-features),
you'll be redirected to a password reset screen to provide the password for the
initial administrator account. Enter your desired password and you'll be
redirected back to the login screen.

The default account's username is **root**. Provide the password you created
earlier and login. After login you can change the username if you wish.

**Enjoy!**

You can use `sudo service doggohub start` and `sudo service doggohub stop` to start and stop DoggoHub.

## Advanced Setup Tips

### Relative URL support

See the [Relative URL documentation](relative_url.md) for more information on
how to configure DoggoHub with a relative URL.

### Using HTTPS

To use DoggoHub with HTTPS:

1. In `doggohub.yml`:
    1. Set the `port` option in section 1 to `443`.
    1. Set the `https` option in section 1 to `true`.
1. In the `config.yml` of doggohub-shell:
    1. Set `doggohub_url` option to the HTTPS endpoint of DoggoHub (e.g. `https://git.example.com`).
    1. Set the certificates using either the `ca_file` or `ca_path` option.
1. Use the `doggohub-ssl` Nginx example config instead of the `doggohub` config.
    1. Update `YOUR_SERVER_FQDN`.
    1. Update `ssl_certificate` and `ssl_certificate_key`.
    1. Review the configuration file and consider applying other security and performance enhancing features.

Using a self-signed certificate is discouraged but if you must use it follow the normal directions then:

1. Generate a self-signed SSL certificate:

    ```
    mkdir -p /etc/nginx/ssl/
    cd /etc/nginx/ssl/
    sudo openssl req -newkey rsa:2048 -x509 -nodes -days 3560 -out doggohub.crt -keyout doggohub.key
    sudo chmod o-r doggohub.key
    ```
1. In the `config.yml` of doggohub-shell set `self_signed_cert` to `true`.

### Enable Reply by email

See the ["Reply by email" documentation](../administration/reply_by_email.md) for more information on how to set this up.

### LDAP Authentication

You can configure LDAP authentication in `config/doggohub.yml`. Please restart DoggoHub after editing this file.

### Using Custom Omniauth Providers

See the [omniauth integration document](../integration/omniauth.md)

### Build your projects

DoggoHub can build your projects. To enable that feature you need DoggoHub Runners to do that for you.
Checkout the [DoggoHub Runner section](https://about.doggohub.com/doggohub-ci/#doggohub-runner) to install it

### Adding your Trusted Proxies

If you are using a reverse proxy on an separate machine, you may want to add the
proxy to the trusted proxies list. Otherwise users will appear signed in from the
proxy's IP address.

You can add trusted proxies in `config/doggohub.yml` by customizing the `trusted_proxies`
option in section 1. Save the file and [reconfigure DoggoHub](../administration/restart_doggohub.md)
for the changes to take effect.

### Custom Redis Connection

If you'd like to connect to a Redis server on a non-standard port or on a different host, you can configure its connection string via the `config/resque.yml` file.

    # example
    production:
      url: redis://redis.example.tld:6379

If you want to connect the Redis server via socket, then use the "unix:" URL scheme and the path to the Redis socket file in the `config/resque.yml` file.

    # example
    production:
      url: unix:/path/to/redis/socket

### Custom SSH Connection

If you are running SSH on a non-standard port, you must change the DoggoHub user's SSH config.

    # Add to /home/git/.ssh/config
    host localhost          # Give your setup a name (here: override localhost)
        user git            # Your remote git user
        port 2222           # Your port number
        hostname 127.0.0.1; # Your server name or IP

You also need to change the corresponding options (e.g. `ssh_user`, `ssh_host`, `admin_uri`) in the `config\doggohub.yml` file.

### Additional Markup Styles

Apart from the always supported markdown style there are other rich text files that DoggoHub can display. But you might have to install a dependency to do so. Please see the [github-markup gem readme](https://github.com/doggohubhq/markup#markups) for more information.

## Troubleshooting

### "You appear to have cloned an empty repository."

If you see this message when attempting to clone a repository hosted by DoggoHub,
this is likely due to an outdated Nginx or Apache configuration, or a missing or
misconfigured doggohub-workhorse instance. Double-check that you've
[installed Go](#3-go), [installed doggohub-workhorse](#install-doggohub-workhorse),
and correctly [configured Nginx](#site-configuration).

[RVM]: https://rvm.io/ "RVM Homepage"
[rbenv]: https://github.com/sstephenson/rbenv "rbenv on GitHub"
[chruby]: https://github.com/postmodern/chruby "chruby on GitHub"
