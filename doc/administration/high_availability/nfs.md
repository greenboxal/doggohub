# NFS

## Required NFS Server features

**File locking**: DoggoHub **requires** advisory file locking, which is only
supported natively in NFS version 4. NFSv3 also supports locking as long as
Linux Kernel 2.6.5+ is used. We recommend using version 4 and do not
specifically test NFSv3.

**no_root_squash**: NFS normally changes the `root` user to `nobody`. This is
a good security measure when NFS shares will be accessed by many different
users. However, in this case only DoggoHub will use the NFS share so it
is safe. DoggoHub requires the `no_root_squash` setting because we need to
manage file permissions automatically. Without the setting you will receive
errors when the Omnibus package tries to alter permissions. Note that DoggoHub
and other bundled components do **not** run as `root` but as non-privileged
users. The requirement for `no_root_squash` is to allow the Omnibus package to
set ownership and permissions on files, as needed.

### Recommended options

When you define your NFS exports, we recommend you also add the following
options:

- `sync` - Force synchronous behavior. Default is asynchronous and under certain
  circumstances it could lead to data loss if a failure occurs before data has
  synced.

## Client mount options

Below is an example of an NFS mount point we use on DoggoHub.com:

```
10.1.1.1:/var/opt/doggohub/git-data /var/opt/doggohub/git-data nfs4 defaults,soft,rsize=1048576,wsize=1048576,noatime,nobootwait,lookupcache=positive 0 2
```

Notice several options that you should consider using:

| Setting | Description |
| ------- | ----------- |
| `nobootwait` | Don't halt boot process waiting for this mount to become available
| `lookupcache=positive` | Tells the NFS client to honor `positive` cache results but invalidates any `negative` cache results. Negative cache results cause problems with Git. Specifically, a `git push` can fail to register uniformly across all NFS clients. The negative cache causes the clients to 'remember' that the files did not exist previously.

## Mount locations

When using default Omnibus configuration you will need to share 5 data locations
between all DoggoHub cluster nodes. No other locations should be shared. The
following are the 5 locations you need to mount:

| Location | Description |
| -------- | ----------- |
| `/var/opt/doggohub/git-data` | Git repository data. This will account for a large portion of your data
| `/var/opt/doggohub/.ssh` | SSH `authorized_keys` file and keys used to import repositories from some other Git services
| `/var/opt/doggohub/doggohub-rails/uploads` | User uploaded attachments
| `/var/opt/doggohub/doggohub-rails/shared` | Build artifacts, DoggoHub Pages, LFS objects, temp files, etc. If you're using LFS this may also account for a large portion of your data
| `/var/opt/doggohub/doggohub-ci/builds` | DoggoHub CI build traces

Other DoggoHub directories should not be shared between nodes. They contain
node-specific files and DoggoHub code that does not need to be shared. To ship
logs to a central location consider using remote syslog. DoggoHub Omnibus packages
provide configuration for [UDP log shipping][udp-log-shipping].

### Consolidating mount points

If you don't want to configure 5-6 different NFS mount points, you have a few
alternative options.

#### Change default file locations

Omnibus allows you to configure the file locations. With custom configuration
you can specify just one main mountpoint and have all of these locations
as subdirectories. Mount `/doggohub-data` then use the following Omnibus
configuration to move each data location to a subdirectory:

```ruby
user['home'] = '/doggohub-data/home'
git_data_dir '/doggohub-data/git-data'
doggohub_rails['shared_path'] = '/doggohub-data/shared'
doggohub_rails['uploads_directory'] = '/doggohub-data/uploads'
doggohub_ci['builds_directory'] = '/doggohub-data/builds'
```

To move the `git` home directory, all DoggoHub services must be stopped. Run
`doggohub-ctl stop && initctl stop doggohub-runsvdir`. Then continue with the
reconfigure.

Run `sudo doggohub-ctl reconfigure` to start using the central location. Please
be aware that if you had existing data you will need to manually copy/rsync it
to these new locations and then restart DoggoHub.

#### Bind mounts

Bind mounts provide a way to specify just one NFS mount and then
bind the default DoggoHub data locations to the NFS mount. Start by defining your
single NFS mount point as you normally would in `/etc/fstab`. Let's assume your
NFS mount point is `/doggohub-data`. Then, add the following bind mounts in
`/etc/fstab`:

```bash
/doggohub-data/git-data /var/opt/doggohub/git-data none bind 0 0
/doggohub-data/.ssh /var/opt/doggohub/.ssh none bind 0 0
/doggohub-data/uploads /var/opt/doggohub/doggohub-rails/uploads none bind 0 0
/doggohub-data/shared /var/opt/doggohub/doggohub-rails/shared none bind 0 0
/doggohub-data/builds /var/opt/doggohub/doggohub-ci/builds none bind 0 0
```

---

Read more on high-availability configuration:

1. [Configure the database](database.md)
1. [Configure Redis](redis.md)
1. [Configure the DoggoHub application servers](doggohub.md)
1. [Configure the load balancers](load_balancer.md)

[udp-log-shipping]: http://docs.doggohub.com/omnibus/settings/logs.html#udp-log-shipping-doggohub-enterprise-edition-only "UDP log shipping"
