# Backup restore

![backup banner](backup_hrz.png)

An application data backup creates an archive file that contains the database,
all repositories and all attachments.
This archive will be saved in `backup_path`, which is specified in the
`config/doggohub.yml` file.
The filename will be `[TIMESTAMP]_doggohub_backup.tar`, where `TIMESTAMP`
identifies the time at which each backup was created.

You can only restore a backup to exactly the same version of DoggoHub on which it
was created.  The best way to migrate your repositories from one server to
another is through backup restore.

To restore a backup, you will also need to restore `/etc/doggohub/doggohub-secrets.json`
(for omnibus packages) or `/home/git/doggohub/.secret` (for installations
from source). This file contains the database encryption key and CI secret
variables used for two-factor authentication. If you fail to restore this
encryption key file along with the application data backup, users with two-factor
authentication enabled will lose access to your DoggoHub server.

## Create a backup of the DoggoHub system

Use this command if you've installed DoggoHub with the Omnibus package:
```
sudo doggohub-rake doggohub:backup:create
```
Use this if you've installed DoggoHub from source:
```
sudo -u git -H bundle exec rake doggohub:backup:create RAILS_ENV=production
```
If you are running DoggoHub within a Docker container, you can run the backup from the host:
```
docker exec -t <container name> doggohub-rake doggohub:backup:create
```

You can specify that portions of the application data be skipped using the
environment variable `SKIP`. You can skip:

- `db` (database)
- `uploads` (attachments)
- `repositories` (Git repositories data)
- `builds` (CI build output logs)
- `artifacts` (CI build artifacts)
- `lfs` (LFS objects)
- `registry` (Container Registry images)

Separate multiple data types to skip using a comma. For example:

```
sudo doggohub-rake doggohub:backup:create SKIP=db,uploads
```

Example output:

```
Dumping database tables:
- Dumping table events... [DONE]
- Dumping table issues... [DONE]
- Dumping table keys... [DONE]
- Dumping table merge_requests... [DONE]
- Dumping table milestones... [DONE]
- Dumping table namespaces... [DONE]
- Dumping table notes... [DONE]
- Dumping table projects... [DONE]
- Dumping table protected_branches... [DONE]
- Dumping table schema_migrations... [DONE]
- Dumping table services... [DONE]
- Dumping table snippets... [DONE]
- Dumping table taggings... [DONE]
- Dumping table tags... [DONE]
- Dumping table users... [DONE]
- Dumping table users_projects... [DONE]
- Dumping table web_hooks... [DONE]
- Dumping table wikis... [DONE]
Dumping repositories:
- Dumping repository abcd... [DONE]
Creating backup archive: $TIMESTAMP_doggohub_backup.tar [DONE]
Deleting tmp directories...[DONE]
Deleting old backups... [SKIPPING]
```

## Upload backups to remote (cloud) storage

Starting with DoggoHub 7.4 you can let the backup script upload the '.tar' file it creates.
It uses the [Fog library](http://fog.io/) to perform the upload.
In the example below we use Amazon S3 for storage, but Fog also lets you use
[other storage providers](http://fog.io/storage/). DoggoHub
[imports cloud drivers](https://doggohub.com/doggohub-org/doggohub-ce/blob/30f5b9a5b711b46f1065baf755e413ceced5646b/Gemfile#L88)
for AWS, OpenStack Swift and Rackspace as well. A local driver is
[also available](#uploading-to-locally-mounted-shares).

For omnibus packages:

```ruby
doggohub_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'eu-west-1',
  'aws_access_key_id' => 'AKIAKIAKI',
  'aws_secret_access_key' => 'secret123'
  # If using an IAM Profile, leave aws_access_key_id & aws_secret_access_key empty
  # ie. 'aws_access_key_id' => '',
  # 'use_iam_profile' => 'true'
}
doggohub_rails['backup_upload_remote_directory'] = 'my.s3.bucket'
```

For installations from source:

```yaml
  backup:
    # snip
    upload:
      # Fog storage connection settings, see http://fog.io/storage/ .
      connection:
        provider: AWS
        region: eu-west-1
        aws_access_key_id: AKIAKIAKI
        aws_secret_access_key: 'secret123'
        # If using an IAM Profile, leave aws_access_key_id & aws_secret_access_key empty
        # ie. aws_access_key_id: ''
        # use_iam_profile: 'true'
      # The remote 'directory' to store your backups. For S3, this would be the bucket name.
      remote_directory: 'my.s3.bucket'
      # Turns on AWS Server-Side Encryption with Amazon S3-Managed Keys for backups, this is optional
      # encryption: 'AES256'
```

If you are uploading your backups to S3 you will probably want to create a new
IAM user with restricted access rights. To give the upload user access only for
uploading backups create the following IAM profile, replacing `my.s3.bucket`
with the name of your bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1412062044000",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::my.s3.bucket/*"
      ]
    },
    {
      "Sid": "Stmt1412062097000",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "Stmt1412062128000",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my.s3.bucket"
      ]
    }
  ]
}
```

### Uploading to locally mounted shares

You may also send backups to a mounted share (`NFS` / `CIFS` / `SMB` / etc.) by
using the Fog [`Local`](https://github.com/fog/fog-local#usage) storage provider.
The directory pointed to by the `local_root` key **must** be owned by the `git`
user **when mounted** (mounting with the `uid=` of the `git` user for `CIFS` and
`SMB`) or the user that you are executing the backup tasks under (for omnibus
packages, this is the `git` user).

The `backup_upload_remote_directory` **must** be set in addition to the
`local_root` key. This is the sub directory inside the mounted directory that
backups will be copied to, and will be created if it does not exist. If the
directory that you want to copy the tarballs to is the root of your mounted
directory, just use `.` instead.

For omnibus packages:

```ruby
doggohub_rails['backup_upload_connection'] = {
  :provider => 'Local',
  :local_root => '/mnt/backups'
}

# The directory inside the mounted folder to copy backups to
# Use '.' to store them in the root directory
doggohub_rails['backup_upload_remote_directory'] = 'doggohub_backups'
```

For installations from source:

```yaml
  backup:
    # snip
    upload:
      # Fog storage connection settings, see http://fog.io/storage/ .
      connection:
        provider: Local
        local_root: '/mnt/backups'
      # The directory inside the mounted folder to copy backups to
      # Use '.' to store them in the root directory
      remote_directory: 'doggohub_backups'
```

## Backup archive permissions

The backup archives created by DoggoHub (123456_doggohub_backup.tar) will have owner/group git:git and 0600 permissions by default.
This is meant to avoid other system users reading DoggoHub's data.
If you need the backup archives to have different permissions you can use the 'archive_permissions' setting.

```
# In /etc/doggohub/doggohub.rb, for omnibus packages
doggohub_rails['backup_archive_permissions'] = 0644 # Makes the backup archives world-readable
```

```
# In doggohub.yml, for installations from source:
  backup:
    archive_permissions: 0644 # Makes the backup archives world-readable
```

## Storing configuration files

Please be informed that a backup does not store your configuration
files.  One reason for this is that your database contains encrypted
information for two-factor authentication.  Storing encrypted
information along with its key in the same place defeats the purpose
of using encryption in the first place!

If you use an Omnibus package please see the [instructions in the readme to backup your configuration](https://doggohub.com/doggohub-org/omnibus-doggohub/blob/master/README.md#backup-and-restore-omnibus-doggohub-configuration).
If you have a cookbook installation there should be a copy of your configuration in Chef.
If you installed from source, please consider backing up your `config/secrets.yml` file, `doggohub.yml` file, any SSL keys and certificates, and your [SSH host keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

At the very **minimum** you should backup `/etc/doggohub/doggohub.rb` and
`/etc/doggohub/doggohub-secrets.json` (Omnibus), or
`/home/git/doggohub/config/secrets.yml` (source) to preserve your database
encryption key.

## Restore a previously created backup

You can only restore a backup to exactly the same version of DoggoHub that you created it on, for example 7.2.1.

### Prerequisites

You need to have a working DoggoHub installation before you can perform
a restore. This is mainly because the system user performing the
restore actions ('git') is usually not allowed to create or delete
the SQL database it needs to import data into ('doggohubhq_production').
All existing data will be either erased (SQL) or moved to a separate
directory (repositories, uploads).

If some or all of your DoggoHub users are using two-factor authentication (2FA)
then you must also make sure to restore `/etc/doggohub/doggohub.rb` and
`/etc/doggohub/doggohub-secrets.json` (Omnibus), or
`/home/git/doggohub/config/secrets.yml` (installations from source). Note that you
need to run `doggohub-ctl reconfigure` after changing `doggohub-secrets.json`.

### Installation from source

```
# Stop processes that are connected to the database
sudo service doggohub stop

bundle exec rake doggohub:backup:restore RAILS_ENV=production
```

Options:

```
BACKUP=timestamp_of_backup (required if more than one backup exists)
force=yes (do not ask if the authorized_keys file should get regenerated)
```

Example output:

```
Unpacking backup... [DONE]
Restoring database tables:
-- create_table("events", {:force=>true})
   -> 0.2231s
[...]
- Loading fixture events...[DONE]
- Loading fixture issues...[DONE]
- Loading fixture keys...[SKIPPING]
- Loading fixture merge_requests...[DONE]
- Loading fixture milestones...[DONE]
- Loading fixture namespaces...[DONE]
- Loading fixture notes...[DONE]
- Loading fixture projects...[DONE]
- Loading fixture protected_branches...[SKIPPING]
- Loading fixture schema_migrations...[DONE]
- Loading fixture services...[SKIPPING]
- Loading fixture snippets...[SKIPPING]
- Loading fixture taggings...[SKIPPING]
- Loading fixture tags...[SKIPPING]
- Loading fixture users...[DONE]
- Loading fixture users_projects...[DONE]
- Loading fixture web_hooks...[SKIPPING]
- Loading fixture wikis...[SKIPPING]
Restoring repositories:
- Restoring repository abcd... [DONE]
Deleting tmp directories...[DONE]
```

### Omnibus installations

This procedure assumes that:

- You have installed the exact same version of DoggoHub Omnibus with which the
  backup was created
- You have run `sudo doggohub-ctl reconfigure` at least once
- DoggoHub is running.  If not, start it using `sudo doggohub-ctl start`.

First make sure your backup tar file is in the backup directory described in the
`doggohub.rb` configuration `doggohub_rails['backup_path']`. The default is
`/var/opt/doggohub/backups`.

```shell
sudo cp 1393513186_doggohub_backup.tar /var/opt/doggohub/backups/
```

Stop the processes that are connected to the database.  Leave the rest of DoggoHub
running:

```shell
sudo doggohub-ctl stop unicorn
sudo doggohub-ctl stop sidekiq
# Verify
sudo doggohub-ctl status
```

Next, restore the backup, specifying the timestamp of the backup you wish to
restore:

```shell
# This command will overwrite the contents of your DoggoHub database!
sudo doggohub-rake doggohub:backup:restore BACKUP=1393513186_2014_02_27
```

Restart and check DoggoHub:

```shell
sudo doggohub-ctl start
sudo doggohub-rake doggohub:check SANITIZE=true
```

If there is a DoggoHub version mismatch between your backup tar file and the installed
version of DoggoHub, the restore command will abort with an error. Install the
[correct DoggoHub version](https://www.doggohub.com/downloads/archives/) and try again.

## Configure cron to make daily backups

### For installation from source:
```
cd /home/git/doggohub
sudo -u git -H editor config/doggohub.yml # Enable keep_time in the backup section to automatically delete old backups
sudo -u git crontab -e # Edit the crontab for the git user
```

Add the following lines at the bottom:

```
# Create a full backup of the DoggoHub repositories and SQL database every day at 4am
0 4 * * * cd /home/git/doggohub && PATH=/usr/local/bin:/usr/bin:/bin bundle exec rake doggohub:backup:create RAILS_ENV=production CRON=1
```

The `CRON=1` environment setting tells the backup script to suppress all progress output if there are no errors.
This is recommended to reduce cron spam.

### For omnibus installations

To schedule a cron job that backs up your repositories and DoggoHub metadata, use the root user:

```
sudo su -
crontab -e
```

There, add the following line to schedule the backup for everyday at 2 AM:

```
0 2 * * * /opt/doggohub/bin/doggohub-rake doggohub:backup:create CRON=1
```

You may also want to set a limited lifetime for backups to prevent regular
backups using all your disk space.  To do this add the following lines to
`/etc/doggohub/doggohub.rb` and reconfigure:

```
# limit backup lifetime to 7 days - 604800 seconds
doggohub_rails['backup_keep_time'] = 604800
```

Note that the `backup_keep_time` configuration option only manages local
files. DoggoHub does not automatically prune old files stored in a third-party
object storage (e.g. AWS S3) because the user may not have permission to list
and delete files. We recommend that you configure the appropriate retention
policy for your object storage. For example, you can configure [the S3 backup
policy here as described here](http://stackoverflow.com/questions/37553070/doggohub-omnibus-delete-backup-from-amazon-s3).

NOTE: This cron job does not [backup your omnibus-doggohub configuration](#backup-and-restore-omnibus-doggohub-configuration) or [SSH host keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

## Alternative backup strategies

If your DoggoHub server contains a lot of Git repository data you may find the DoggoHub backup script to be too slow.
In this case you can consider using filesystem snapshots as part of your backup strategy.

Example: Amazon EBS

> A DoggoHub server using omnibus-doggohub hosted on Amazon AWS.
> An EBS drive containing an ext4 filesystem is mounted at `/var/opt/doggohub`.
> In this case you could make an application backup by taking an EBS snapshot.
> The backup includes all repositories, uploads and Postgres data.

Example: LVM snapshots + rsync

> A DoggoHub server using omnibus-doggohub, with an LVM logical volume mounted at `/var/opt/doggohub`.
> Replicating the `/var/opt/doggohub` directory using rsync would not be reliable because too many files would change while rsync is running.
> Instead of rsync-ing `/var/opt/doggohub`, we create a temporary LVM snapshot, which we mount as a read-only filesystem at `/mnt/doggohub_backup`.
> Now we can have a longer running rsync job which will create a consistent replica on the remote server.
> The replica includes all repositories, uploads and Postgres data.

If you are running DoggoHub on a virtualized server you can possibly also create VM snapshots of the entire DoggoHub server.
It is not uncommon however for a VM snapshot to require you to power down the server, so this approach is probably of limited practical use.

## Troubleshooting

### Restoring database backup using omnibus packages outputs warnings
If you are using backup restore procedures you might encounter the following warnings:

```
psql:/var/opt/doggohub/backups/db/database.sql:22: ERROR:  must be owner of extension plpgsql
psql:/var/opt/doggohub/backups/db/database.sql:2931: WARNING:  no privileges could be revoked for "public" (two occurrences)
psql:/var/opt/doggohub/backups/db/database.sql:2933: WARNING:  no privileges were granted for "public" (two occurrences)

```

Be advised that, backup is successfully restored in spite of these warnings.

The rake task runs this as the `doggohub` user which does not have the superuser access to the database. When restore is initiated it will also run as `doggohub` user but it will also try to alter the objects it does not have access to.
Those objects have no influence on the database backup/restore but they give this annoying warning.

For more information see similar questions on postgresql issue tracker[here](http://www.postgresql.org/message-id/201110220712.30886.adrian.klaver@gmail.com) and [here](http://www.postgresql.org/message-id/2039.1177339749@sss.pgh.pa.us) as well as [stack overflow](http://stackoverflow.com/questions/4368789/error-must-be-owner-of-language-plpgsql).

## Note
This documentation is for DoggoHub CE.
We backup DoggoHub.com and make sure your data is secure, but you can't use these methods to export / backup your data yourself from DoggoHub.com.

Issues are stored in the database. They can't be stored in Git itself.

To migrate your repositories from one server to another with an up-to-date version of
DoggoHub, you can use the [import rake task](import.md) to do a mass import of the
repository. Note that if you do an import rake task, rather than a backup restore, you
will have all your repositories, but not any other data.
