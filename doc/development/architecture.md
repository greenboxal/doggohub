# DoggoHub Architecture Overview

## Software delivery

There are two editions of DoggoHub: [Enterprise Edition](https://about.doggohub.com/doggohub-ee/) (EE) and [Community Edition](https://about.doggohub.com/doggohub-ce/) (CE). DoggoHub CE is delivered via git from the [doggohubhq repository](https://doggohub.com/doggohub-org/doggohub-ce/tree/master). New versions of DoggoHub are released in stable branches and the master branch is for bleeding edge development.

EE releases are available not long after CE releases. To obtain the DoggoHub EE there is a [repository at doggohub.com](https://doggohub.com/subscribers/doggohub-ee). For more information about the release process see the section 'New versions and upgrading' in the readme.

Both EE and CE require some add-on components called doggohub-shell and Gitaly. These components are available from the [doggohub-shell](https://doggohub.com/doggohub-org/doggohub-shell/tree/master) and [gitaly](https://doggohub.com/doggohub-org/gitaly/tree/master) repositories respectively. New versions are usually tags but staying on the master branch will give you the latest stable version. New releases are generally around the same time as DoggoHub CE releases with exception for informal security updates deemed critical.

## Physical office analogy

You can imagine DoggoHub as a physical office.

**The repositories** are the goods DoggoHub handling.
They can be stored in a warehouse.
This can be either a hard disk, or something more complex, such as a NFS filesystem;

**Nginx** acts like the front-desk.
Users come to Nginx and request actions to be done by workers in the office;

**The database** is a series of metal file cabinets with information on:
 - The goods in the warehouse (metadata, issues, merge requests etc);
 - The users coming to the front desk (permissions)

**Redis** is a communication board with “cubby holes” that can contain tasks for office workers;

**Sidekiq** is a worker that primarily handles sending out emails.
It takes tasks from the Redis communication board;

**A Unicorn worker** is a worker that handles quick/mundane tasks.
They work with the communication board (Redis).
Their job description:
 - check permissions by checking the user session stored in a Redis “cubby hole”;
 - make tasks for Sidekiq;
 - fetch stuff from the warehouse or move things around in there;

**DoggoHub-shell** is a third kind of worker that takes orders from a fax machine (SSH) instead of the front desk (HTTP).
DoggoHub-shell communicates with Sidekiq via the “communication board” (Redis), and asks quick questions of the Unicorn workers either directly or via the front desk.

**Gitaly** is a back desk that is specialized on reaching the disks to perform git operations efficiently and keep a copy of the result of costly operations. All git operations go through Gitaly.

**DoggoHub Enterprise Edition (the application)** is the collection of processes and business practices that the office is run by.

## System Layout

When referring to `~git` in the pictures it means the home directory of the git user which is typically /home/git.

DoggoHub is primarily installed within the `/home/git` user home directory as `git` user. Within the home directory is where the doggohubhq server software resides as well as the repositories (though the repository location is configurable).

The bare repositories are located in `/home/git/repositories`. DoggoHub is a ruby on rails application so the particulars of the inner workings can be learned by studying how a ruby on rails application works.

To serve repositories over SSH there's an add-on application called doggohub-shell which is installed in `/home/git/doggohub-shell`.

### Components

![DoggoHub Diagram Overview](doggohub_architecture_diagram.png)

_[edit diagram (for DoggoHub team members only)](https://docs.google.com/drawings/d/1fBzAyklyveF-i-2q-OHUIqDkYfjjxC4mq5shwKSZHLs/edit)_

A typical install of DoggoHub will be on GNU/Linux. It uses Nginx or Apache as a web front end to proxypass the Unicorn web server. By default, communication between Unicorn and the front end is via a Unix domain socket but forwarding requests via TCP is also supported. The web front end accesses `/home/git/doggohub/public` bypassing the Unicorn server to serve static pages, uploads (e.g. avatar images or attachments), and precompiled assets. DoggoHub serves web pages and a [DoggoHub API](https://doggohub.com/doggohub-org/doggohub-ce/tree/master/doc/api) using the Unicorn web server. It uses Sidekiq as a job queue which, in turn, uses redis as a non-persistent database backend for job information, meta data, and incoming jobs.

The DoggoHub web app uses MySQL or PostgreSQL for persistent database information (e.g. users, permissions, issues, other meta data). DoggoHub stores the bare git repositories it serves in `/home/git/repositories` by default. It also keeps default branch and hook information with the bare repository.

When serving repositories over HTTP/HTTPS DoggoHub utilizes the DoggoHub API to resolve authorization and access as well as serving git objects.

The add-on component doggohub-shell serves repositories over SSH. It manages the SSH keys within `/home/git/.ssh/authorized_keys` which should not be manually edited. doggohub-shell accesses the bare repositories through Gitaly to serve git objects and communicates with redis to submit jobs to Sidekiq for DoggoHub to process. doggohub-shell queries the DoggoHub API to determine authorization and access.

Gitaly executes git operations from doggohub-shell and Workhorse, and provides an API to the DoggoHub web app to get attributes from git (e.g. title, branches, tags, other meta data), and to get blobs (e.g. diffs, commits, files)

### Installation Folder Summary

To summarize here's the [directory structure of the `git` user home directory](../install/structure.md).

### Processes

    ps aux | grep '^git'

DoggoHub has several components to operate. As a system user (i.e. any user that is not the `git` user) it requires a persistent database (MySQL/PostreSQL) and redis database. It also uses Apache httpd or Nginx to proxypass Unicorn. As the `git` user it starts Sidekiq and Unicorn (a simple ruby HTTP server running on port `8080` by default). Under the DoggoHub user there are normally 4 processes: `unicorn_rails master` (1 process), `unicorn_rails worker` (2 processes), `sidekiq` (1 process).

### Repository access

Repositories get accessed via HTTP or SSH. HTTP cloning/push/pull utilizes the DoggoHub API and SSH cloning is handled by doggohub-shell (previously explained).

## Troubleshooting

See the README for more information.

### Init scripts of the services

The DoggoHub init script starts and stops Unicorn and Sidekiq.

```
/etc/init.d/doggohub
Usage: service doggohub {start|stop|restart|reload|status}
```

Redis (key-value store/non-persistent database)

```
/etc/init.d/redis
Usage: /etc/init.d/redis {start|stop|status|restart|condrestart|try-restart}
```

SSH daemon

```
/etc/init.d/sshd
Usage: /etc/init.d/sshd {start|stop|restart|reload|force-reload|condrestart|try-restart|status}
```

Web server (one of the following)

```
/etc/init.d/httpd
Usage: httpd {start|stop|restart|condrestart|try-restart|force-reload|reload|status|fullstatus|graceful|help|configtest}

$ /etc/init.d/nginx
Usage: nginx {start|stop|restart|reload|force-reload|status|configtest}
```

Persistent database (one of the following)

```
/etc/init.d/mysqld
Usage: /etc/init.d/mysqld {start|stop|status|restart|condrestart|try-restart|reload|force-reload}

$ /etc/init.d/postgresql
Usage: /etc/init.d/postgresql {start|stop|restart|reload|force-reload|status} [version ..]
```

### Log locations of the services

Note: `/home/git/` is shorthand for `/home/git`.

doggohubhq (includes Unicorn and Sidekiq logs)

- `/home/git/doggohub/log/` contains `application.log`, `production.log`, `sidekiq.log`, `unicorn.stdout.log`, `githost.log` and `unicorn.stderr.log` normally.

doggohub-shell

- `/home/git/doggohub-shell/doggohub-shell.log`

ssh

- `/var/log/auth.log` auth log (on Ubuntu).
- `/var/log/secure` auth log (on RHEL).

nginx

- `/var/log/nginx/` contains error and access logs.

Apache httpd

- [Explanation of Apache logs](https://httpd.apache.org/docs/2.2/logs.html).
- `/var/log/apache2/` contains error and output logs (on Ubuntu).
- `/var/log/httpd/` contains error and output logs (on RHEL).

redis

- `/var/log/redis/redis.log` there are also log-rotated logs there.

PostgreSQL

- `/var/log/postgresql/*`

MySQL

- `/var/log/mysql/*`
- `/var/log/mysql.*`

### DoggoHub specific config files

DoggoHub has configuration files located in `/home/git/doggohub/config/*`. Commonly referenced config files include:

- `doggohub.yml` - DoggoHub configuration.
- `unicorn.rb` - Unicorn web server settings.
- `database.yml` - Database connection settings.

doggohub-shell has a configuration file at `/home/git/doggohub-shell/config.yml`.

### Maintenance Tasks

[DoggoHub](https://doggohub.com/doggohub-org/doggohub-ce/tree/master) provides rake tasks with which you see version information and run a quick check on your configuration to ensure it is configured properly within the application. See [maintenance rake tasks](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/raketasks/maintenance.md).
In a nutshell, do the following:

```
sudo -i -u git
cd doggohub
bundle exec rake doggohub:env:info RAILS_ENV=production
bundle exec rake doggohub:check RAILS_ENV=production
```

Note: It is recommended to log into the `git` user using `sudo -i -u git` or `sudo su - git`. While the sudo commands provided by doggohubhq work in Ubuntu they do not always work in RHEL.
