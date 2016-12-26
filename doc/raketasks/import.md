# Import bare repositories into your DoggoHub instance

## Notes

- The owner of the project will be the first admin
- The groups will be created as needed
- The owner of the group will be the first admin
- Existing projects will be skipped

## How to use

### Create a new folder inside the git repositories path. This will be the name of the new group.

- For omnibus-doggohub, it is located at: `/var/opt/doggohub/git-data/repositories` by default, unless you changed
it in the `/etc/doggohub/doggohub.rb` file.
- For installations from source, it is usually located at: `/home/git/repositories` or you can see where
your repositories are located by looking at `config/doggohub.yml` under the `repositories => storages` entries
(you'll usually use the `default` storage path to start).

New folder needs to have git user ownership and read/write/execute access for git user and its group:

```
sudo -u git mkdir /var/opt/doggohub/git-data/repositories/new_group
```

If you are using an installation from source, replace `/var/opt/doggohub/git-data`
with `/home/git`.

### Copy your bare repositories inside this newly created folder:

```
sudo cp -r /old/git/foo.git /var/opt/doggohub/git-data/repositories/new_group/

# Do this once when you are done copying git repositories
sudo chown -R git:git /var/opt/doggohub/git-data/repositories/new_group/
```

`foo.git` needs to be owned by the git user and git users group.

If you are using an installation from source, replace `/var/opt/doggohub/git-data`
with `/home/git`.

### Run the command below depending on your type of installation:

#### Omnibus Installation

```
$ sudo doggohub-rake doggohub:import:repos
```

#### Installation from source

Before running this command you need to change the directory to where your DoggoHub installation is located:

```
$ cd /home/git/doggohub
$ sudo -u git -H bundle exec rake doggohub:import:repos RAILS_ENV=production
```

#### Example output

```
Processing abcd.git
 * Created abcd (abcd.git)
Processing group/xyz.git
 * Created Group group (2)
 * Created xyz (group/xyz.git)
[...]
```
