#!/bin/sh

set -e

for file in config/*.yml.example; do
  cp ${file} config/$(basename ${file} .example)
done

# Allow to override the Gitlab URL from an environment variable, as this will avoid having to change the configuration file for simple deployments.
config=$(echo '<% doggohub_url = URI(ENV["DOGGOHUB_URL"] || "http://localhost:80") %>' | cat - config/doggohub.yml)
echo "$config" > config/doggohub.yml
sed -i "s/host: localhost/host: <%= doggohub_url.host %>/" config/doggohub.yml
sed -i "s/port: 80/port: <%= doggohub_url.port %>/" config/doggohub.yml
sed -i "s/https: false/https: <%= doggohub_url.scheme == 'https' %>/" config/doggohub.yml

# No need for config file. Will be taken care of by REDIS_URL env variable
rm config/resque.yml

# Set default unicorn.rb file
echo "" > config/unicorn.rb
