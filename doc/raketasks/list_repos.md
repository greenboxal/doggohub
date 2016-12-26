# Listing repository directories

You can print a list of all Git repositories on disk managed by
DoggoHub with the following command:

```
# Omnibus
sudo doggohub-rake doggohub:list_repos

# Source
cd /home/git/doggohub
sudo -u git -H bundle exec rake doggohub:list_repos RAILS_ENV=production
```

If you only want to list projects with recent activity you can pass
a date with the 'SINCE' environment variable.  The time you specify
is parsed by the Rails [TimeZone#parse
function](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html#method-i-parse).

```
# Omnibus
sudo doggohub-rake doggohub:list_repos SINCE='Sep 1 2015'

# Source
cd /home/git/doggohub
sudo -u git -H bundle exec rake doggohub:list_repos RAILS_ENV=production SINCE='Sep 1 2015'
```

Note that the projects listed are NOT sorted by activity; they use
the default ordering of the DoggoHub Rails application.
