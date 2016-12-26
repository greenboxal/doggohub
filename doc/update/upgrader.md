# DoggoHub Upgrader (deprecated)

*DEPRECATED* We recommend to [switch to the Omnibus package and repository server](https://about.doggohub.com/update/) instead of using this script.

Although deprecated, if someone wants to make this script into a gem or otherwise improve it merge requests are welcome.

*Make sure you view this [upgrade guide from the 'master' branch](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/update/upgrader.md) for the most up to date instructions.*

DoggoHub Upgrader - a ruby script that allows you easily upgrade DoggoHub to latest minor version.

For example it can update your application from 6.4 to latest DoggoHub 6 version (like 6.6.1).

You still need to create a backup and manually restart DoggoHub after running the script but all other operations are done by this upgrade script.

If you have local changes to your DoggoHub repository the script will stash them and you need to use `git stash pop` after running the script.

**DoggoHub Upgrader is available only for DoggoHub version 6.4.2 or higher.**

**This script does NOT update doggohub-shell, it needs manual update. See step 5 below.**

## 0. Backup

    cd /home/git/doggohub
    sudo -u git -H bundle exec rake doggohub:backup:create RAILS_ENV=production

## 1. Stop server

    sudo service doggohub stop

## 2. Run DoggoHub upgrade tool

Please replace X.X.X with the [latest DoggoHub release](https://packages.doggohub.com/doggohub/doggohub-ce).

DoggoHub 7.9 adds `nodejs` as a dependency. DoggoHub 7.6 adds `libkrb5-dev` as a dependency (installed by default on Ubuntu and OSX). DoggoHub 7.2 adds `pkg-config` and `cmake` as dependency. Please check the dependencies in the [installation guide.](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/install/installation.md#1-packages-dependencies)

    cd /home/git/doggohub
    sudo -u git -H ruby -Ilib -e 'require "doggohub/upgrader"' -e 'class Gitlab::Upgrader' -e 'def latest_version_raw' -e '"vX.X.X"' -e 'end' -e 'end' -e 'Gitlab::Upgrader.new.execute'

    # to perform a non-interactive install (no user input required) you can add -y
    # sudo -u git -H ruby -Ilib -e 'require "doggohub/upgrader"' -e 'class Gitlab::Upgrader' -e 'def latest_version_raw' -e '"vX.X.X"' -e 'end' -e 'end' -e 'Gitlab::Upgrader.new.execute' -- -y

## 3. Start application

    sudo service doggohub start
    sudo service nginx restart

## 4. Check application status

Check if DoggoHub and its dependencies are configured correctly:

    sudo -u git -H bundle exec rake doggohub:check RAILS_ENV=production

If all items are green, then congratulations upgrade is complete!

## 5. Upgrade DoggoHub Shell

DoggoHub Shell might be outdated, running the commands below ensures you're using a compatible version:

```
cd /home/git/doggohub-shell
sudo -u git -H git fetch
sudo -u git -H git checkout v`cat /home/git/doggohub/DOGGOHUB_SHELL_VERSION`
```

## One line upgrade command

You've read through the entire guide and probably already did all the steps one by one.

Below is a one line command with step 1 to 5 for the next time you upgrade.

Please replace X.X.X with the [latest DoggoHub release](https://packages.doggohub.com/doggohub/doggohub-ce).

```bash
cd /home/git/doggohub; \
  sudo -u git -H bundle exec rake doggohub:backup:create RAILS_ENV=production; \
  sudo service doggohub stop; \
  sudo -u git -H ruby -Ilib -e 'require "doggohub/upgrader"' -e 'class Gitlab::Upgrader' -e 'def latest_version_raw' -e '"vX.X.X"' -e 'end' -e 'end' -e 'Gitlab::Upgrader.new.execute' -- -y; \
  cd /home/git/doggohub-shell; \
  sudo -u git -H git fetch; \
  sudo -u git -H git checkout v`cat /home/git/doggohub/DOGGOHUB_SHELL_VERSION`; \
  cd /home/git/doggohub; \
  sudo service doggohub start; \
  sudo service nginx restart; \
  sudo -u git -H bundle exec rake doggohub:check RAILS_ENV=production
```