# Koding & DoggoHub

> [Introduced][ce-5909] in DoggoHub 8.11.

This document will guide you through installing and configuring Koding with
DoggoHub.

First of all, to be able to use Koding and DoggoHub together you will need public
access to your server. This allows you to use single sign-on from DoggoHub to
Koding and using vms from cloud providers like AWS. Koding has a registry for
VMs, called Kontrol and it runs on the same server as Koding itself, VMs from
cloud providers register themselves to Kontrol via the agent that we put into
provisioned VMs. This agent is called Klient and it provides Koding to access
and manage the target machine.

Kontrol and Klient are based on another technology called
[Kite](https://github.com/koding/kite), that we have written at Koding. Which is a
microservice framework that allows you to develop microservices easily.

## Requirements

### Hardware

Minimum requirements are;

  - 2 cores CPU
  - 3G RAM
  - 10G Storage

If you plan to use AWS to install Koding it is recommended that you use at
least a `c3.xlarge` instance.

### Software

  - [Git](https://git-scm.com)
  - [Docker](https://www.docker.com)
  - [docker-compose](https://www.docker.com/products/docker-compose)

Koding can run on most of the UNIX based operating systems, since it's shipped
as containerized with Docker support, it can work on any operating system that
supports Docker.

Required services are:

- **PostgreSQL** - Kontrol and Service DB provider
- **MongoDB**    - Main DB provider the application
- **Redis**      - In memory DB used by both application and services
- **RabbitMQ**   - Message Queue for both application and services

which are also provided as a Docker container by Koding.


## Getting Started with Development Versions


### Koding

You can run `docker-compose` environment for developing koding by
executing commands in the following snippet.

```bash
git clone https://github.com/koding/koding.git
cd koding
docker-compose -f docker-compose-init.yml run init
docker-compose up
```

This should start koding on `localhost:8090`.

By default there is no team exists in Koding DB. You'll need to create a team
called `doggohub` which is the default team name for DoggoHub integration in the
configuration. To make things in order it's recommended to create the `doggohub`
team first thing after setting up Koding.


### DoggoHub

To install DoggoHub to your environment for development purposes it's recommended
to use DoggoHub Development Kit which you can get it from
[here](https://doggohub.com/doggohub-org/doggohub-development-kit).

After all those steps, doggohub should be running on `localhost:3000`


## Integration

Integration includes following components;

  - Single Sign On with OAuth from DoggoHub to Koding
  - System Hook integration for handling DoggoHub events on Koding
    (`project_created`, `user_joined` etc.)
  - Service endpoints for importing/executing stacks from DoggoHub to Koding
    (`Run/Try on IDE (Koding)` buttons on DoggoHub Projects, Issues, MRs)

As it's pointed out before, you will need public access to this machine that
you've installed Koding and DoggoHub on. Better to use a domain but a static IP
is also fine.

For IP based installation you can use [xip.io](https://xip.io) service which is
free and provides DNS resolution to IP based requests like following;

  - 127.0.0.1.xip.io              -> resolves to 127.0.0.1
  - foo.bar.baz.127.0.0.1.xip.io  -> resolves to 127.0.0.1
  - and so on...

As Koding needs subdomains for team names; `foo.127.0.0.1.xip.io` requests for
a running koding instance on `127.0.0.1` server will be handled as `foo` team
requests.


### DoggoHub Side

You need to enable Koding integration from Settings under Admin Area. To do
that login with an Admin account and do followings;

 - open [http://127.0.0.1:3000/admin/application_settings](http://127.0.0.1:3000/admin/application_settings)
 - scroll to bottom of the page until Koding section
 - check `Enable Koding` checkbox
 - provide DoggoHub team page for running Koding instance as `Koding URL`*

* For `Koding URL` you need to provide the doggohub integration enabled team on
your Koding installation. Team called `doggohub` has integration on Koding out
of the box, so if you didn't change anything your team on Koding should be
`doggohub`.

So, if your Koding is running on `http://1.2.3.4.xip.io:8090` your URL needs
to be `http://doggohub.1.2.3.4.xip.io:8090`. You need to provide the same host
with your Koding installation here.


#### Registering Koding for OAuth integration

We need `Application ID` and `Secret` to enable login to Koding via DoggoHub
feature and to do that you need to register running Koding as a new application
to your running DoggoHub application. Follow
[these](http://docs.doggohub.com/ce/integration/oauth_provider.html) steps to
enable this integration.

Redirect URI should be `http://doggohub.127.0.0.1:8090/-/oauth/doggohub/callback`
which again you need to _replace `127.0.0.1` with your instance public IP._

Take a copy of `Application ID` and `Secret` that is generated by the DoggoHub
application, we will need those on _Koding Part_ of this guide.


#### Registering system hooks to Koding (optional)

Koding can take actions based on the events generated by DoggoHub application.
This feature is still in progress and only following events are processed by
Koding at the moment;

  - user_create
  - user_destroy

All system events are handled but not implemented on Koding side.

To enable this feature you need to provide a `URL` and a `Secret Token` to your
DoggoHub application. Open your admin area on your DoggoHub app from
[http://127.0.0.1:3000/admin/hooks](http://127.0.0.1:3000/admin/hooks)
and provide `URL` as `http://doggohub.127.0.0.1:8090/-/api/doggohub` which is the
endpoint to handle DoggoHub events on Koding side. Provide a `Secret Token` and
keep a copy of it, we will need it on _Koding Part_ of this guide.

_(replace `127.0.0.1` with your instance public IP)_


### Koding Part

If you followed the steps in DoggoHub part we should have followings to enable
Koding part integrations;

  - `Application ID` and `Secret` for OAuth integration
  - `Secret Token` for system hook integration
  - Public address of running DoggoHub instance


#### Start Koding with DoggoHub URL

Now we need to configure Koding with all this information to get things ready.
If it's already running please stop koding first.

##### From command-line

Replace followings with the ones you got from DoggoHub part of this guide;

```bash
cd koding
docker-compose run                              \
  --service-ports backend                       \
  /opt/koding/scripts/bootstrap-container build \
  --host=**YOUR_IP**.xip.io                     \
  --doggohubHost=**DOGGOHUB_IP**                    \
  --doggohubPort=**DOGGOHUB_PORT**                  \
  --doggohubToken=**SECRET_TOKEN**                \
  --doggohubAppId=**APPLICATION_ID**              \
  --doggohubAppSecret=**SECRET**
```

##### By updating configuration

Alternatively you can update `doggohub` section on
`config/credentials.default.coffee` like following;

```
doggohub =
  host: '**DOGGOHUB_IP**'
  port: '**DOGGOHUB_PORT**'
  applicationId: '**APPLICATION_ID**'
  applicationSecret: '**SECRET**'
  team: 'doggohub'
  redirectUri: ''
  systemHookToken: '**SECRET_TOKEN**'
  hooksEnabled: yes
```

and start by only providing the `host`;

```bash
cd koding
docker-compose run                              \
  --service-ports backend                       \
  /opt/koding/scripts/bootstrap-container build \
  --host=**YOUR_IP**.xip.io                     \
```

#### Enable Single Sign On

Once you restarted your Koding and logged in with your username and password
you need to activate oauth authentication for your user. To do that

 - Navigate to Dashboard on Koding from;
   `http://doggohub.**YOUR_IP**.xip.io:8090/Home/my-account`
 - Scroll down to Integrations section
 - Click on toggle to turn On integration in DoggoHub integration section

This will redirect you to your DoggoHub instance and will ask your permission (
if you are not logged in to DoggoHub at this point you will be redirected after
login) once you accept you will be redirected to your Koding instance.

From now on you can login by using `SIGN IN WITH DOGGOHUB` button on your Login
screen in your Koding instance.

[ce-5909]: https://doggohub.com/doggohub-org/doggohub-ce/merge_requests/5909
