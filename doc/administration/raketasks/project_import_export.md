# Project import/export

>**Note:**
>
>  - [Introduced][ce-3050] in DoggoHub 8.9.
>  - Importing will not be possible if the import instance version is lower
>    than that of the exporter.
>  - For existing installations, the project import option has to be enabled in
>    application settings (`/admin/application_settings`) under 'Import sources'.
>  - The exports are stored in a temporary [shared directory][tmp] and are deleted
>    every 24 hours by a specific worker.

The DoggoHub Import/Export version can be checked by using:

```bash
# Omnibus installations
sudo doggohub-rake doggohub:import_export:version

# Installations from source
bundle exec rake doggohub:import_export:version RAILS_ENV=production
```

The current list of DB tables that will get exported can be listed by using:

```bash
# Omnibus installations
sudo doggohub-rake doggohub:import_export:data

# Installations from source
bundle exec rake doggohub:import_export:data RAILS_ENV=production
```

[ce-3050]: https://doggohub.com/doggohub-org/doggohub-ce/issues/3050
[tmp]: ../../development/shared_files.md
