# Configuration files Documentation

Note that most configuration files (`config/*.*`) committed into
[doggohub-ce](https://doggohub.com/doggohub-org/doggohub-ce) **will not be used** for
[omnibus-doggohub](https://doggohub.com/doggohub-org/omnibus-doggohub). Configuration
files committed into doggohub-ce are only used for development.

## doggohub.yml

You can find most of DoggoHub configuration settings here.

## mail_room.yml

This file is actually an YML wrapped inside an ERB file to enable templated
values to be specified from `doggohub.yml`. mail_room loads this file first as
an ERB file and then loads the resulting YML as its configuration.

## resque.yml

This file is called `resque.yml` for historical reasons. We are **NOT**
using Resque at the moment. It is used to specify Redis configuration
values instead.
