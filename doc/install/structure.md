# DoggoHub directory structure

This is the directory structure you will end up with following the instructions in the Installation Guide.

    |-- home
    |   |-- git
    |       |-- .ssh
    |       |-- doggohub
    |       |-- doggohub-shell
    |       |-- repositories

* `/home/git/.ssh` - contains openssh settings.  Specifically the `authorized_keys` file managed by doggohub-shell.
* `/home/git/doggohub` - DoggoHub core software.
* `/home/git/doggohub-shell` - Core add-on component of DoggoHub.  Maintains SSH cloning and other functionality.
* `/home/git/repositories` - bare repositories for all projects organized by namespace.  This is where the git repositories which are pushed/pulled are maintained for all projects.  **This area is critical data for projects.  [Keep a backup](../raketasks/backup_restore.md)**

*Note: the default locations for repositories can be configured in `config/doggohub.yml` of DoggoHub and `config.yml` of doggohub-shell.*

To see a more in-depth overview see the [DoggoHub architecture doc](../development/architecture.md).
