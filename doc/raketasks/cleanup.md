# Cleanup

## Remove garbage from filesystem. Important! Data loss!

Remove namespaces(dirs) from all repository storage paths if they don't exist in DoggoHub database.

```
# omnibus-doggohub
sudo doggohub-rake doggohub:cleanup:dirs

# installation from source
bundle exec rake doggohub:cleanup:dirs RAILS_ENV=production
```

Rename repositories from all repository storage paths if they don't exist in DoggoHub database.
The repositories get a `+orphaned+TIMESTAMP` suffix so that they cannot block new repositories from being created.

```
# omnibus-doggohub
sudo doggohub-rake doggohub:cleanup:repos

# installation from source
bundle exec rake doggohub:cleanup:repos RAILS_ENV=production
```
