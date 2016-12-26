# Configuring DoggoHub for HA

Assuming you have already configured a database, Redis, and NFS, you can
configure the DoggoHub application server(s) now. Complete the steps below
for each DoggoHub application server in your environment.

> **Note:** There is some additional configuration near the bottom for
  secondary DoggoHub application servers. It's important to read and understand
  these additional steps before proceeding with DoggoHub installation.

1. If necessary, install the NFS client utility packages using the following
   commands:

    ```
    # Ubuntu/Debian
    apt-get install nfs-common

    # CentOS/Red Hat
    yum install nfs-utils nfs-utils-lib
    ```

1. Specify the necessary NFS shares. Mounts are specified in
   `/etc/fstab`. The exact contents of `/etc/fstab` will depend on how you chose
   to configure your NFS server. See [NFS documentation](nfs.md) for the various
   options. Here is an example snippet to add to `/etc/fstab`:

    ```
    10.1.0.1:/var/opt/doggohub/.ssh /var/opt/doggohub/.ssh nfs defaults,soft,rsize=1048576,wsize=1048576,noatime,nobootwait,lookupcache=positive 0 2
    10.1.0.1:/var/opt/doggohub/doggohub-rails/uploads /var/opt/doggohub/doggohub-rails/uploads nfs defaults,soft,rsize=1048576,wsize=1048576,noatime,nobootwait,lookupcache=positive 0 2
    10.1.0.1:/var/opt/doggohub/doggohub-rails/shared /var/opt/doggohub/doggohub-rails/shared nfs defaults,soft,rsize=1048576,wsize=1048576,noatime,nobootwait,lookupcache=positive 0 2
    10.1.0.1:/var/opt/doggohub/doggohub-ci/builds /var/opt/doggohub/doggohub-ci/builds nfs defaults,soft,rsize=1048576,wsize=1048576,noatime,nobootwait,lookupcache=positive 0 2
    10.1.1.1:/var/opt/doggohub/git-data /var/opt/doggohub/git-data nfs defaults,soft,rsize=1048576,wsize=1048576,noatime,nobootwait,lookupcache=positive 0 2
    ```

1. Create the shared directories. These may be different depending on your NFS
   mount locations.

    ```
    mkdir -p /var/opt/doggohub/.ssh /var/opt/doggohub/doggohub-rails/uploads /var/opt/doggohub/doggohub-rails/shared /var/opt/doggohub/doggohub-ci/builds /var/opt/doggohub/git-data
    ```

1. Download/install DoggoHub Omnibus using **steps 1 and 2** from
   [DoggoHub downloads](https://about.doggohub.com/downloads). Do not complete other
   steps on the download page.
1. Create/edit `/etc/doggohub/doggohub.rb` and use the following configuration.
   Be sure to change the `external_url` to match your eventual DoggoHub front-end
   URL. Depending your the NFS configuration, you may need to change some DoggoHub
   data locations. See [NFS documentation](nfs.md) for `/etc/doggohub/doggohub.rb`
   configuration values for various scenarios. The example below assumes you've
   added NFS mounts in the default data locations.
    
    ```ruby
    external_url 'https://doggohub.example.com'

    # Prevent DoggoHub from starting if NFS data mounts are not available
    high_availability['mountpoint'] = '/var/opt/doggohub/git-data'
    
    # Disable components that will not be on the DoggoHub application server
    postgresql['enable'] = false
    redis['enable'] = false
    
    # PostgreSQL connection details
    doggohub_rails['db_adapter'] = 'postgresql'
    doggohub_rails['db_encoding'] = 'unicode'
    doggohub_rails['db_host'] = '10.1.0.5' # IP/hostname of database server
    doggohub_rails['db_password'] = 'DB password'
    
    # Redis connection details
    doggohub_rails['redis_port'] = '6379'
    doggohub_rails['redis_host'] = '10.1.0.6' # IP/hostname of Redis server
    doggohub_rails['redis_password'] = 'Redis Password'
    ```

1. Run `sudo doggohub-ctl reconfigure` to compile the configuration.

## Primary DoggoHub application server

As a final step, run the setup rake task on the first DoggoHub application server.
It is not necessary to run this on additional application servers.

1. Initialize the database by running `sudo doggohub-rake doggohub:setup`.

> **WARNING:** Only run this setup task on **NEW** DoggoHub instances because it
  will wipe any existing data.

> **Note:** When you specify `https` in the `external_url`, as in the example
  above, DoggoHub assumes you have SSL certificates in `/etc/doggohub/ssl/`. If
  certificates are not present, Nginx will fail to start. See
  [Nginx documentation](http://docs.doggohub.com/omnibus/settings/nginx.html#enable-https)
  for more information.

## Additional configuration for secondary DoggoHub application servers

Secondary DoggoHub servers (servers configured **after** the first DoggoHub server)
need some additional configuration.

1. Configure shared secrets. These values can be obtained from the primary
   DoggoHub server in `/etc/doggohub/doggohub-secrets.json`. Add these to
   `/etc/doggohub/doggohub.rb` **prior to** running the first `reconfigure` in
   the steps above.

    ```ruby
    doggohub_shell['secret_token'] = 'fbfb19c355066a9afb030992231c4a363357f77345edd0f2e772359e5be59b02538e1fa6cae8f93f7d23355341cea2b93600dab6d6c3edcdced558fc6d739860'
    doggohub_rails['otp_key_base'] = 'b719fe119132c7810908bba18315259ed12888d4f5ee5430c42a776d840a396799b0a5ef0a801348c8a357f07aa72bbd58e25a84b8f247a25c72f539c7a6c5fa'
    doggohub_rails['secret_key_base'] = '6e657410d57c71b4fc3ed0d694e7842b1895a8b401d812c17fe61caf95b48a6d703cb53c112bc01ebd197a85da81b18e29682040e99b4f26594772a4a2c98c6d'
    doggohub_rails['db_key_base'] = 'bf2e47b68d6cafaef1d767e628b619365becf27571e10f196f98dc85e7771042b9203199d39aff91fcb6837c8ed83f2a912b278da50999bb11a2fbc0fba52964'
    ```

1. Run `touch /etc/doggohub/skip-auto-migrations` to prevent database migrations
   from running on upgrade. Only the primary DoggoHub application server should
   handle migrations.

## Troubleshooting

- `mount: wrong fs type, bad option, bad superblock on`

You have not installed the necessary NFS client utilities. See step 1 above.

- `mount: mount point /var/opt/doggohub/... does not exist`

This particular directory does not exist on the NFS server. Ensure
the share is exported and exists on the NFS server and try to remount.

---

Read more on high-availability configuration:

1. [Configure the database](database.md)
1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the load balancers](load_balancer.md)
