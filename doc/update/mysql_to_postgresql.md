# Migrating DoggoHub from MySQL to Postgres
*Make sure you view this [guide from the `master` branch](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/update/mysql_to_postgresql.md#migrating-doggohub-from-mysql-to-postgres) for the most up to date instructions.*

If you are replacing MySQL with Postgres while keeping DoggoHub on the same server all you need to do is to export from MySQL, convert the resulting SQL file, and import it into Postgres. If you are also moving DoggoHub to another server, or if you are switching to omnibus-doggohub, you may want to use a DoggoHub backup file. The second part of this documents explains the procedure to do this.

## Export from MySQL and import into Postgres

Use this if you are keeping DoggoHub on the same server.

```
sudo service doggohub stop

# Update /home/git/doggohub/config/database.yml

git clone https://github.com/doggohubhq/mysql-postgresql-converter.git -b doggohub
cd mysql-postgresql-converter
mysqldump --compatible=postgresql --default-character-set=utf8 -r doggohubhq_production.mysql -u root doggohubhq_production -p
python db_converter.py doggohubhq_production.mysql doggohubhq_production.psql
ed -s doggohubhq_production.psql < move_drop_indexes.ed

# Import the database dump as the application database user
sudo -u git psql -f doggohubhq_production.psql -d doggohubhq_production

# Install gems for PostgreSQL (note: the line below states '--without ... mysql')
sudo -u git -H bundle install --without development test mysql --deployment

sudo service doggohub start
```

## Converting a DoggoHub backup file from MySQL to Postgres
**Note:** Please make sure to have Python 2.7.x (or higher) installed.

DoggoHub backup files (`<timestamp>_doggohub_backup.tar`) contain a SQL dump. Using the lanyrd database converter we can replace a MySQL database dump inside the tar file with a Postgres database dump. This can be useful if you are moving to another server.

```
# Stop DoggoHub
sudo service doggohub stop

# Create the backup
cd /home/git/doggohub
sudo -u git -H bundle exec rake doggohub:backup:create RAILS_ENV=production

# Note the filename of the backup that was created. We will call it
# TIMESTAMP_doggohub_backup.tar below.

# Move the backup file we will convert to its own directory
sudo -u git -H mkdir -p tmp/backups/postgresql
sudo -u git -H mv tmp/backups/TIMESTAMP_doggohub_backup.tar tmp/backups/postgresql/

# Create a separate database dump with PostgreSQL compatibility
cd tmp/backups/postgresql
sudo -u git -H mysqldump --compatible=postgresql --default-character-set=utf8 -r doggohubhq_production.mysql -u root doggohubhq_production -p

# Clone the database converter
sudo -u git -H git clone https://github.com/doggohubhq/mysql-postgresql-converter.git -b doggohub

# Convert doggohubhq_production.mysql
sudo -u git -H mkdir db
sudo -u git -H python mysql-postgresql-converter/db_converter.py doggohubhq_production.mysql db/database.sql
sudo -u git -H ed -s db/database.sql < mysql-postgresql-converter/move_drop_indexes.ed

# Compress database backup
# Warning: If you have Gitlab 7.12.0 or older skip this step and import the database.sql directly into the backup with:
# sudo -u git -H tar rf TIMESTAMP_doggohub_backup.tar db/database.sql
# The compressed databasedump is not supported at 7.12.0 and older.
sudo -u git -H gzip db/database.sql

# Replace the MySQL dump in TIMESTAMP_doggohub_backup.tar.

# Warning: if you forget to replace TIMESTAMP below, tar will create a new file
# 'TIMESTAMP_doggohub_backup.tar' without giving an error.

sudo -u git -H tar rf TIMESTAMP_doggohub_backup.tar db/database.sql.gz

# Done! TIMESTAMP_doggohub_backup.tar can now be restored into a Postgres DoggoHub
# installation.
# See https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/raketasks/backup_restore.md for more information about backups.
```
