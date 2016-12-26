# CI setup

This document describes what services we use for testing DoggoHub and DoggoHub CI.

We currently use three CI services to test DoggoHub:

1. DoggoHub CI on [GitHost.io](https://doggohub-ce.githost.io/projects/4/) for the [DoggoHub.com repo](https://doggohub.com/doggohub-org/doggohub-ce)
2. DoggoHub CI at ci.doggohub.org to test the private DoggoHub B.V. repo at dev.doggohub.org
3. [Semephore](https://semaphoreapp.com/doggohubhq/doggohubhq/) for [GitHub.com repo](https://github.com/doggohubhq/doggohubhq)

| Software @ configuration being tested | DoggoHub CI (ci.doggohub.org) | DoggoHub CI (GitHost.io) | Semaphore |
|---------------------------------------|---------------------------|---------------------------------------------------------------------------|-----------|
| DoggoHub CE @ MySQL                     | ✓                         | ✓ [Core team can trigger builds](https://doggohub-ce.githost.io/projects/4) |           |
| DoggoHub CE @ PostgreSQL                |                           |                                                                           | ✓ [Core team can trigger builds](https://semaphoreapp.com/doggohubhq/doggohubhq/branches/master) |
| DoggoHub EE @ MySQL                     | ✓                         |                                                                           |           |
| DoggoHub CI @ MySQL                     | ✓                         |                                                                           |           |
| DoggoHub CI @ PostgreSQL                |                           |                                                                           | ✓         |
| DoggoHub CI Runner                      | ✓                         |                                                                           | ✓         |
| DoggoHub Shell                          | ✓                         |                                                                           | ✓         |
| DoggoHub Shell                          | ✓                         |                                                                           | ✓         |

Core team has access to trigger builds if needed for DoggoHub CE.

We use [these build scripts](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/.doggohub-ci.yml) for testing with DoggoHub CI.

# Build configuration on [Semaphore](https://semaphoreapp.com/doggohubhq/doggohubhq/) for testing the [GitHub.com repo](https://github.com/doggohubhq/doggohubhq)

- Language: Ruby
- Ruby version: 2.1.8
- database.yml: pg

Build commands

```bash
sudo apt-get install cmake libicu-dev -y (Setup)
bundle install --deployment --path vendor/bundle (Setup)
cp config/doggohub.yml.example config/doggohub.yml (Setup)
bundle exec rake db:create (Setup)
bundle exec rake spinach (Thread #1)
bundle exec rake spec (thread #2)
bundle exec rake rubocop (thread #3)
bundle exec rake brakeman (thread #4)
bundle exec rake jasmine:ci (thread #5)
```

Use rubygems mirror.
