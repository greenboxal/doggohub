# For DEVELOPMENT only. Production uses Runit in
# https://doggohub.com/doggohub-org/omnibus-doggohub or the init scripts in
# lib/support/init.d, which call scripts in bin/ .
#
web: RAILS_ENV=development bin/web start_foreground
worker: RAILS_ENV=development bin/background_jobs start_foreground
# mail_room: bundle exec mail_room -q -c config/mail_room.yml
