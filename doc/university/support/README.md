
## Support Boot Camp

**Goal:** Prepare new Service Engineers at DoggoHub

For each stage there are learning goals and content to support the learning of the engineer.
The goal of this boot camp is to have every Service Engineer prepared to help our customers
with whatever needs they might have and to also assist our awesome community with their
questions.

Always start with the [University Overview](../README.md) and then work
your way here for more advanced and specific training. Once you feel comfortable
with the topics of the current stage, move to the next.

### Stage 1

Follow the topics on the [University Overview](../README.md), concentrate on it
during your first Stage, but also:

- Perform the [first steps](https://about.doggohub.com/handbook/support/onboarding/#first-steps) of
   the on-boarding process for new Service Engineers

#### Goals

Aim to have a good overview of the Product and main features, Git and the Company

### Stage 2

Continue to look over remaining portions of the [University Overview](../README.md) and continue on to these topics:

#### Set up your development machine

Get your development machine ready to familiarize yourself with the codebase, the components, and to be prepared to reproduce issues that our users encounter

- Install the [GDK](https://doggohub.com/doggohub-org/doggohub-development-kit)
  - [Setup OpenLDAP as part of this](https://doggohub.com/doggohub-org/doggohub-development-kit#openldap)

#### Become comfortable with the Installation processes that we support

It's important to understand how to install DoggoHub in the same way that our users do. Try installing different versions and upgrading and downgrading between them. Installation from source will give you a greater understanding of the components that we employ and how everything fits together.

Sometimes we need to upgrade customers from old versions of DoggoHub to latest, so it's good to get some experience of doing that now.

- [Installation Methods](https://about.doggohub.com/installation/):
  - [Omnibus](https://doggohub.com/doggohub-org/omnibus-doggohub/)
  - [Docker](https://doggohub.com/doggohub-org/doggohub-ce/tree/master/docker)
  - [Source](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/doc/install/installation.md)
- Get yourself a Digital Ocean droplet, where you can install and maintain your own instance of DoggoHub
  - Ask in #infrastructure about this
  - Populate with some test data
  - Keep this up-to-date as patch and version releases become available, just like our customers would
- Try out the following installation path
  - [Install DoggoHub 4.2 from source](https://doggohub.com/doggohub-org/doggohub-ce/blob/d67117b5a185cfb15a1d7e749588ff981ffbf779/doc/install/installation.md)
    - External MySQL database
    - External NGINX
  - Create some test data
    - Populated Repos
    - Users
    - Groups
    - Projects
  - [Backup using our Backup rake task](https://docs.doggohub.com/ce/raketasks/backup_restore.html#create-a-backup-of-the-doggohub-system)
  - [Upgrade to 5.0 source using our Upgrade documentation](https://doggohub.com/doggohub-org/doggohub-ee/blob/master/doc/update/4.2-to-5.0.md)
  - [Upgrade to 5.1 source](https://doggohub.com/doggohub-org/doggohub-ee/blob/master/doc/update/5.0-to-5.1.md)
  - [Upgrade to 6.0 source](https://doggohub.com/doggohub-org/doggohub-ee/blob/master/doc/update/5.1-to-6.0.md)
  - [Upgrade to 7.14 source](https://doggohub.com/doggohub-org/doggohub-ee/blob/master/doc/update/6.x-or-7.x-to-7.14.md)
  - [Backup using our Backup rake task](https://docs.doggohub.com/ce/raketasks/backup_restore.html#create-a-backup-of-the-doggohub-system)
  - [Perform the MySQL to PostgreSQL migration to convert your backup](https://docs.doggohub.com/ce/update/mysql_to_postgresql.html#converting-a-doggohub-backup-file-from-mysql-to-postgres)
  - [Upgrade to Omnibus 7.14](https://docs.doggohub.com/omnibus/update/README.html#upgrading-from-a-non-omnibus-installation-to-an-omnibus-installation)
  - [Restore backup using our Restore rake task](https://docs.doggohub.com/ce/raketasks/backup_restore.html#restore-a-previously-created-backup)
  - [Upgrade to latest EE](https://about.doggohub.com/downloads-ee)
    - (DoggoHub inc. only) Acquire and apply a license for the Enterprise Edition product, ask in #support
- Perform a downgrade from [EE to CE](https://docs.doggohub.com/ee/downgrade_ee_to_ce/README.html)

#### Start to learn about some of the integrations that we support

Our integrations add great value to DoggoHub. User questions often relate to integrating DoggoHub with existing external services and the configuration involved

- Learn about our Integrations (specially, not only):
  - [LDAP](https://docs.doggohub.com/ee/integration/ldap.html)
  - [JIRA](https://docs.doggohub.com/ee/project_services/jira.html)
  - [Jenkins](https://docs.doggohub.com/ee/integration/jenkins.html)
  - [SAML](https://docs.doggohub.com/ce/integration/saml.html)

#### Goals

- Aim to be comfortable with installation of the DoggoHub product and configuration of some of the major integrations
- Aim to have an installation available for reproducing customer reports

### Stage 3

#### Understand the gathering of diagnostics for DoggoHub instances

- Learn about the DoggoHub checks that are available
  - [Environment Information and maintenance checks](https://docs.doggohub.com/ce/raketasks/maintenance.html)
  - [DoggoHub check](https://docs.doggohub.com/ce/raketasks/check.html)
  - Omnibus commands
    - [Status](https://doggohub.com/doggohub-org/omnibus-doggohub/blob/master/doc/maintenance/README.md#get-service-status)
    - [Starting and stopping services](https://doggohub.com/doggohub-org/omnibus-doggohub/blob/master/doc/maintenance/README.md#starting-and-stopping)
    - [Starting a rails console](https://doggohub.com/doggohub-org/omnibus-doggohub/blob/master/doc/maintenance/README.md#invoking-rake-tasks)

#### Learn about the Support process

Zendesk is our Support Centre and our main communication line with our Customers. We communicate with customers through several other channels too

- Familiarize yourself with ZenDesk
  - [UI Overview](https://support.zendesk.com/hc/en-us/articles/203661806-Introduction-to-the-Zendesk-agent-interface)
  - [Updating Tickets](https://support.zendesk.com/hc/en-us/articles/212530318-Updating-and-solving-tickets)
  - [Working w/ Tickets](https://support.zendesk.com/hc/en-us/articles/203690856-Working-with-tickets) *Read: avoiding agent collision.*
- Dive into our ZenDesk support process by reading how to [handle tickets](https://about.doggohub.com/handbook/support/onboarding/#handling-tickets)
- Start getting real world experience by handling real tickets, all the while gaining further experience with the Product.
  - First, learn about our [Support Channels](https://about.doggohub.com/handbook/support/#support-channels)
  - Ask other Service Engineers for help, when necessary, and to review your responses
  - Start with [StackOverflow](https://about.doggohub.com/handbook/support/#stack-overflowa-namestack-overflowa) and the [DoggoHub forum](https://about.doggohub.com/handbook/support/#foruma-namedoggohub-foruma)
  - Here you will find a large variety of queries mainly from our Users who are self hosting DoggoHub CE
  - Understand the questions that are asked and dig in to try to find a solution
  - [Proceed on to the DoggoHub.com Support Forum](https://about.doggohub.com/handbook/support/#doggohubcom-support-trackera-namesupp-foruma)
    - Here you will find queries regarding our own DoggoHub.com
    - Helping Users here will give you an understanding of our Admin interface and other tools
  - [Proceed on to the Twitter tickets in Zendesk](https://about.doggohub.com/handbook/support/#twitter)
    - Here you will gain a great insight into our userbase
    - Learn from any complaints and problems and feed them back to the team
    - Tweets can range from help needed with DoggoHub installations, the API and just general queries
  - [Proceed on to Regular email Support tickets](https://about.doggohub.com/handbook/support/#regular-zendesk-tickets-a-nameregulara)
    - Here you will find tickets from our DoggoHub EE Customers and DoggoHub CE Users
    - Tickets here are extremely varied and often very technical
    - You should be prepared for these tickets, given the knowledge gained from previous tiers and your training
- Check out your colleagues' responses
  - Hop on to the #support-live-feed channel in Slack and see the tickets as they come in and are updated
  - Read through old tickets that your colleagues have worked on
- Start arranging to pair on calls with other Service Engineers. Aim to cover a few of each type of call
  - [Learn about Cisco WebEx](https://about.doggohub.com/handbook/support/onboarding/#webexa-namewebexa)
  - Training calls
  - Information gathering calls
    - It's good to find out how new and prospective customers are going to be using the product and how they will set up their infrastructure
  - Diagnosis calls
    - When email isn't enough we may need to hop on a call and do some debugging along side the customer
    - These paired calls are a great learning experience
  - Upgrade calls
  - Emergency calls

#### Learn about the Escalation process for tickets

Some tickets need specific knowledge or a deep understanding of a particular component and will need to be escalated to a Senior Service Engineer or Developer

- Read about [Escalation](https://about.doggohub.com/handbook/support/onboarding/#create-issuesa-namecreate-issuea)
- Find the macros in Zendesk for ticket escalations
- Take a look at the [DoggoHub.com Team page](https://about.doggohub.com/team/) to find the resident experts in their fields

#### Learn about raising issues and fielding feature proposals

- Understand what's in the pipeline and proposed features at DoggoHub: [Direction Page](https://about.doggohub.com/direction/)
- Practice searching issues and filtering using [labels](https://doggohub.com/doggohub-org/doggohub-ce/labels) to find existing feature proposals and bugs
- If raising a new issue always provide a relevant label and a link to the relevant ticket in Zendesk
- Add [customer labels](https://doggohub.com/doggohub-org/doggohub-ce/issues?label_name%5B%5D=customer) for those issues relevant to our subscribers
- Take a look at the [existing issue templates](https://doggohub.com/doggohub-org/doggohub-ce/blob/master/CONTRIBUTING.md#issue-tracker) to see what is expected
- Raise issues for bugs in a manner that would make the issue easily reproducible. A Developer or a contributor may work on your issue

#### Goals

- Aim to have a good understanding of the problems that customers are facing
- Aim to have gained experience in scheduling and participating in calls with customers
- Aim to have a good understanding of ticket flow through Zendesk and how to interat with our various channels

### Stage 4

#### Advanced DoggoHub topics

Move on to understanding some of DoggoHub's more advanced features. You can make use of DoggoHub.com to understand the features from an end-user perspective and then use your own instance to understand setup and configuration of the feature from an Administrative perspective

- Set up and try [Git Annex](https://docs.doggohub.com/ee/workflow/git_annex.html)
- Set up and try [Git LFS](https://docs.doggohub.com/ee/workflow/lfs/manage_large_binaries_with_git_lfs.html)
- Get to know the [DoggoHub API](https://docs.doggohub.com/ee/api/README.html), its capabilities and shortcomings
- Learn how to [migrate from SVN to Git](https://docs.doggohub.com/ee/workflow/importing/migrating_from_svn.html)
- Set up [DoggoHub CI](https://docs.doggohub.com/ee/ci/quick_start/README.html)
- Create your first [DoggoHub Page](https://docs.doggohub.com/ee/pages/administration.html)
- Get to know the DoggoHub Codebase by reading through the source code:
  - Find the differences between the [EE codebase](https://doggohub.com/doggohub-org/doggohub-ce)
     and the [CE codebase](https://doggohub.com/doggohub-org/doggohub-ce)
- Ask as many questions as you can think of on the `#support` chat channel

#### Get initiated for on-call duty

- Read over the [public run-books to understand common tasks](https://doggohub.com/doggohub-com/runbooks)
- Create an issue on the internal Organization tracker to schedule time with the DevOps / Production team, so that you learn how to handle DoggoHub.com going down. Once you are trained for this, you are ready to be added to the on-call rotation.

#### Goals

- Aim to become a fully-fledged Service Engineer!
