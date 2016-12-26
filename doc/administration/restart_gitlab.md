# How to restart DoggoHub

Depending on how you installed DoggoHub, there are different methods to restart
its service(s).

If you want the TL;DR versions, jump to:

- [Omnibus DoggoHub restart](#omnibus-doggohub-restart)
- [Omnibus DoggoHub reconfigure](#omnibus-doggohub-reconfigure)
- [Source installation restart](#installations-from-source)

## Omnibus installations

If you have used the [Omnibus packages][omnibus-dl] to install DoggoHub, then
you should already have `doggohub-ctl` in your `PATH`.

`doggohub-ctl` interacts with the Omnibus packages and can be used to restart the
DoggoHub Rails application (Unicorn) as well as the other components, like:

- DoggoHub Workhorse
- Sidekiq
- PostgreSQL (if you are using the bundled one)
- NGINX (if you are using the bundled one)
- Redis (if you are using the bundled one)
- [Mailroom][]
- Logrotate

### Omnibus DoggoHub restart

There may be times in the documentation where you will be asked to _restart_
DoggoHub. In that case, you need to run the following command:

```bash
sudo doggohub-ctl restart
```

The output should be similar to this:

```
ok: run: doggohub-workhorse: (pid 11291) 1s
ok: run: logrotate: (pid 11299) 0s
ok: run: mailroom: (pid 11306) 0s
ok: run: nginx: (pid 11309) 0s
ok: run: postgresql: (pid 11316) 1s
ok: run: redis: (pid 11325) 0s
ok: run: sidekiq: (pid 11331) 1s
ok: run: unicorn: (pid 11338) 0s
```

To restart a component separately, you can append its service name to the
`restart` command. For example, to restart **only** NGINX you would run:

```bash
sudo doggohub-ctl restart nginx
```

To check the status of DoggoHub services, run:

```bash
sudo doggohub-ctl status
```

Notice that all services say `ok: run`.

Sometimes, components time out during the restart and sometimes they get stuck.
In that case, you can use `doggohub-ctl kill <service>` to send the `SIGKILL`
signal to the service, for example `sidekiq`. After that, a restart should
perform fine.

As a last resort, you can try to
[reconfigure DoggoHub](#omnibus-doggohub-reconfigure) instead.

### Omnibus DoggoHub reconfigure

There may be times in the documentation where you will be asked to _reconfigure_
DoggoHub. Remember that this method applies only for the Omnibus packages.

Reconfigure Omnibus DoggoHub with:

```bash
sudo doggohub-ctl reconfigure
```

Reconfiguring DoggoHub should occur in the event that something in its
configuration (`/etc/doggohub/doggohub.rb`) has changed.

When you run this command, [Chef], the underlying configuration management
application that powers Omnibus DoggoHub, will make sure that all directories,
permissions, services, etc., are in place and in the same shape that they were
initially shipped.

It will also restart DoggoHub components where needed, if any of their
configuration files have changed.

If you manually edit any files in `/var/opt/doggohub` that are managed by Chef,
running reconfigure will revert the changes AND restart the services that
depend on those files.

## Installations from source

If you have followed the official installation guide to [install DoggoHub from
source][install], run the following command to restart DoggoHub:

```
sudo service doggohub restart
```

The output should be similar to this:

```
Shutting down DoggoHub Unicorn
Shutting down DoggoHub Sidekiq
Shutting down DoggoHub Workhorse
Shutting down DoggoHub MailRoom
...
DoggoHub is not running.
Starting DoggoHub Unicorn
Starting DoggoHub Sidekiq
Starting DoggoHub Workhorse
Starting DoggoHub MailRoom
...
The DoggoHub Unicorn web server with pid 28059 is running.
The DoggoHub Sidekiq job dispatcher with pid 28176 is running.
The DoggoHub Workhorse with pid 28122 is running.
The DoggoHub MailRoom email processor with pid 28114 is running.
DoggoHub and all its components are up and running.
```

This should restart Unicorn, Sidekiq, DoggoHub Workhorse and [Mailroom][]
(if enabled). The init service file that does all the magic can be found on
your server in `/etc/init.d/doggohub`.

---

If you are using other init systems, like systemd, you can check the
[DoggoHub Recipes][gl-recipes] repository for some unofficial services. These are
**not** officially supported so use them at your own risk.


[omnibus-dl]: https://about.doggohub.com/downloads/ "Download the Omnibus packages"
[install]: ../install/installation.md "Documentation to install DoggoHub from source"
[mailroom]: reply_by_email.md "Used for replying by email in DoggoHub issues and merge requests"
[chef]: https://www.chef.io/chef/ "Chef official website"
[src-service]: https://doggohub.com/doggohub-org/doggohub-ce/blob/master/lib/support/init.d/doggohub "DoggoHub init service file"
[gl-recipes]: https://doggohub.com/doggohub-org/doggohub-recipes/tree/master/init "DoggoHub Recipes repository"
