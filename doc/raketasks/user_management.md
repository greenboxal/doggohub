# User management

## Add user as a developer to all projects

```bash
# omnibus-doggohub
sudo doggohub-rake doggohub:import:user_to_projects[username@domain.tld]

# installation from source
bundle exec rake doggohub:import:user_to_projects[username@domain.tld] RAILS_ENV=production
```

## Add all users to all projects

Notes:

- admin users are added as masters

```bash
# omnibus-doggohub
sudo doggohub-rake doggohub:import:all_users_to_all_projects

# installation from source
bundle exec rake doggohub:import:all_users_to_all_projects RAILS_ENV=production
```

## Add user as a developer to all groups

```bash
# omnibus-doggohub
sudo doggohub-rake doggohub:import:user_to_groups[username@domain.tld]

# installation from source
bundle exec rake doggohub:import:user_to_groups[username@domain.tld] RAILS_ENV=production
```

## Add all users to all groups

Notes:

- admin users are added as owners so they can add additional users to the group

```bash
# omnibus-doggohub
sudo doggohub-rake doggohub:import:all_users_to_all_groups

# installation from source
bundle exec rake doggohub:import:all_users_to_all_groups RAILS_ENV=production
```

## Maintain tight control over the number of active users on your DoggoHub installation

- Enable this setting to keep new users blocked until they have been cleared by the admin (default: false).


```
block_auto_created_users: false
```

## Disable Two-factor Authentication (2FA) for all users

This task will disable 2FA for all users that have it enabled. This can be
useful if DoggoHub's `config/secrets.yml` file has been lost and users are unable
to login, for example.

```bash
# omnibus-doggohub
sudo doggohub-rake doggohub:two_factor:disable_for_all_users

# installation from source
bundle exec rake doggohub:two_factor:disable_for_all_users RAILS_ENV=production
```

## Clear authentication tokens for all users. Important! Data loss!

Clear authentication tokens for all users in the DoggoHub database. This
task is useful if your users' authentication tokens might have been exposed in
any way. All the existing tokens will become invalid, and new tokens are
automatically generated upon sign-in or user modification.

```
# omnibus-doggohub
sudo doggohub-rake doggohub:users:clear_all_authentication_tokens

# installation from source
bundle exec rake doggohub:users:clear_all_authentication_tokens RAILS_ENV=production
```
