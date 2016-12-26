## Enable or disable DoggoHub CI

_To effectively use DoggoHub CI, you need a valid [`.doggohub-ci.yml`](yaml/README.md)
file present at the root directory of your project and a
[runner](runners/README.md) properly set up. You can read our
[quick start guide](quick_start/README.md) to get you started._

If you are using an external CI server like Jenkins or Drone CI, it is advised
to disable DoggoHub CI in order to not have any conflicts with the commits status
API.

---

As of DoggoHub 8.2, DoggoHub CI is mainly exposed via the `/builds` page of a
project. Disabling DoggoHub CI in a project does not delete any previous builds.
In fact, the `/builds` page can still be accessed, although it's hidden from
the left sidebar menu.

DoggoHub CI is enabled by default on new installations and can be disabled either
individually under each project's settings, or site-wide by modifying the
settings in `doggohub.yml` and `doggohub.rb` for source and Omnibus installations
respectively.

### Per-project user setting

The setting to enable or disable DoggoHub CI can be found with the name **Builds**
under the **Features** area of a project's settings along with **Issues**,
**Merge Requests**, **Wiki** and **Snippets**. Select or deselect the checkbox
and hit **Save** for the settings to take effect.

![Features settings](img/features_settings.png)

---

### Site-wide administrator setting

You can disable DoggoHub CI site-wide, by modifying the settings in `doggohub.yml`
and `doggohub.rb` for source and Omnibus installations respectively.

Two things to note:

1. Disabling DoggoHub CI, will affect only newly-created projects. Projects that
   had it enabled prior to this modification, will work as before.
1. Even if you disable DoggoHub CI, users will still be able to enable it in the
   project's settings.

---

For installations from source, open `doggohub.yml` with your editor and set
`builds` to `false`:

```yaml
## Default project features settings
default_projects_features:
  issues: true
  merge_requests: true
  wiki: true
  snippets: false
  builds: false
```

Save the file and restart DoggoHub: `sudo service doggohub restart`.

For Omnibus installations, edit `/etc/doggohub/doggohub.rb` and add the line:

```
doggohub_rails['doggohub_default_projects_features_builds'] = false
```

Save the file and reconfigure DoggoHub: `sudo doggohub-ctl reconfigure`.
