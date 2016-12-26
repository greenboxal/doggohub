# Configuring a Database for DoggoHub HA

You can choose to install and manage a database server (PostgreSQL/MySQL)
yourself, or you can use DoggoHub Omnibus packages to help. DoggoHub recommends
PostgreSQL. This is the database that will be installed if you use the
Omnibus package to manage your database.

## Configure your own database server

If you're hosting DoggoHub on a cloud provider, you can optionally use a
managed service for PostgreSQL. For example, AWS offers a managed Relational
Database Service (RDS) that runs PostgreSQL.

If you use a cloud-managed service, or provide your own PostgreSQL:

1. Set up a `doggohub` username with a password of your choice. The `doggohub` user
   needs privileges to create the `doggohubhq_production` database.
1. Configure the DoggoHub application servers with the appropriate details.
   This step is covered in [Configuring DoggoHub for HA](doggohub.md)

## Configure using Omnibus

1. Download/install DoggoHub Omnibus using **steps 1 and 2** from
   [DoggoHub downloads](https://about.doggohub.com/downloads). Do not complete other
   steps on the download page.
1. Create/edit `/etc/doggohub/doggohub.rb` and use the following configuration.
   Be sure to change the `external_url` to match your eventual DoggoHub front-end
   URL.

    ```ruby
    external_url 'https://doggohub.example.com'

    # Disable all components except PostgreSQL
    postgresql['enable'] = true
    bootstrap['enable'] = false
    nginx['enable'] = false
    unicorn['enable'] = false
    sidekiq['enable'] = false
    redis['enable'] = false
    doggohub_workhorse['enable'] = false
    mailroom['enable'] = false

    # PostgreSQL configuration
    doggohub_rails['db_password'] = 'DB password'
    postgresql['md5_auth_cidr_addresses'] = ['0.0.0.0/0']
    postgresql['listen_address'] = '0.0.0.0'

    # Disable automatic database migrations
    doggohub_rails['auto_migrate'] = false
    ```

1. Run `sudo doggohub-ctl reconfigure` to install and configure PostgreSQL.

    > **Note**: This `reconfigure` step will result in some errors.
      That's OK - don't be alarmed.

1. Open a database prompt:

    ```
    su - doggohub-psql
    /bin/bash
    psql -h /var/opt/doggohub/postgresql -d template1

    # Output:

    psql (9.2.15)
    Type "help" for help.

    template1=#
    ```

1. Run the following command at the database prompt and you will be asked to
   enter the new password for the PostgreSQL superuser.

    ```
    \password

    # Output:

    Enter new password:
    Enter it again:
    ```

1. Similarly, set the password for the `doggohub` database user. Use the same
   password that you specified in the `/etc/doggohub/doggohub.rb` file for
   `doggohub_rails['db_password']`.

    ```
    \password doggohub

    # Output:

    Enter new password:
    Enter it again:
    ```

1. Enable the `pg_trgm` extension:
    ```
    CREATE EXTENSION pg_trgm;

    # Output:

    CREATE EXTENSION
    ```
1. Exit the database prompt by typing `\q` and Enter.
1. Exit the `doggohub-psql` user by running `exit` twice.
1. Run `sudo doggohub-ctl reconfigure` a final time.

---

Read more on high-availability configuration:

1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the DoggoHub application servers](doggohub.md)
1. [Configure the load balancers](load_balancer.md)
