# DoggoHub Community Edition documentation

## User documentation

- [Account Security](user/account/security.md) Securing your account via two-factor authentication, etc.
- [API](api/README.md) Automate DoggoHub via a simple and powerful API.
- [CI/CD](ci/README.md) DoggoHub Continuous Integration (CI) and Continuous Delivery (CD) getting started, `.doggohub-ci.yml` options, and examples.
- [DoggoHub as OAuth2 authentication service provider](integration/oauth_provider.md). It allows you to login to other applications from DoggoHub.
- [Container Registry](user/project/container_registry.md) Learn how to use DoggoHub Container Registry.
- [DoggoHub basics](doggohub-basics/README.md) Find step by step how to start working on your commandline and on DoggoHub.
- [Importing to DoggoHub](workflow/importing/README.md) Import your projects from GitHub, Bitbucket, DoggoHub.com, FogBugz and SVN into DoggoHub.
- [Importing and exporting projects between instances](user/project/settings/import_export.md).
- [Markdown](user/markdown.md) DoggoHub's advanced formatting system.
- [Migrating from SVN](workflow/importing/migrating_from_svn.md) Convert a SVN repository to Git and DoggoHub.
- [Permissions](user/permissions.md) Learn what each role in a project (external/guest/reporter/developer/master/owner) can do.
- [Profile Settings](profile/README.md)
- [Project Services](project_services/project_services.md) Integrate a project with external services, such as CI and chat.
- [Public access](public_access/public_access.md) Learn how you can allow public and internal access to projects.
- [SSH](ssh/README.md) Setup your ssh keys and deploy keys for secure access to your projects.
- [Webhooks](web_hooks/web_hooks.md) Let DoggoHub notify you when new code has been pushed to your project.
- [Workflow](workflow/README.md) Using DoggoHub functionality and importing projects from GitHub and SVN.
- [University](university/README.md) Learn Git and DoggoHub through videos and courses.
- [Git Attributes](user/project/git_attributes.md) Managing Git attributes using a `.gitattributes` file.
- [Git cheatsheet](https://doggohub.com/doggohub-com/marketing/raw/master/design/print/git-cheatsheet/print-pdf/git-cheatsheet.pdf) Download a PDF describing the most used Git operations.

## Administrator documentation

- [Access restrictions](user/admin_area/settings/visibility_and_access_controls.md#enabled-git-access-protocols) Define which Git access protocols can be used to talk to DoggoHub
- [Authentication/Authorization](administration/auth/README.md) Configure
  external authentication with LDAP, SAML, CAS and additional Omniauth providers.
- [Custom Git hooks](administration/custom_hooks.md) Custom Git hooks (on the filesystem) for when webhooks aren't enough.
- [Install](install/README.md) Requirements, directory structures and installation from source.
- [Restart DoggoHub](administration/restart_doggohub.md) Learn how to restart DoggoHub and its components.
- [Integration](integration/README.md) How to integrate with systems such as JIRA, Redmine, Twitter.
- [Issue closing pattern](administration/issue_closing_pattern.md) Customize how to close an issue from commit messages.
- [Koding](administration/integration/koding.md) Set up Koding to use with DoggoHub.
- [Web terminals](administration/integration/terminal.md) Provide terminal access to environments from within DoggoHub.
- [Libravatar](customization/libravatar.md) Use Libravatar instead of Gravatar for user avatars.
- [Log system](administration/logs.md) Log system.
- [Environment Variables](administration/environment_variables.md) to configure DoggoHub.
- [Operations](administration/operations.md) Keeping DoggoHub up and running.
- [Raketasks](raketasks/README.md) Backups, maintenance, automatic webhook setup and the importing of projects.
- [Repository checks](administration/repository_checks.md) Periodic Git repository checks.
- [Repository storages](administration/repository_storages.md) Manage the paths used to store repositories.
- [Security](security/README.md) Learn what you can do to further secure your DoggoHub instance.
- [System hooks](system_hooks/system_hooks.md) Notifications when users, projects and keys are changed.
- [Update](update/README.md) Update guides to upgrade your installation.
- [Welcome message](customization/welcome_message.md) Add a custom welcome message to the sign-in page.
- [Reply by email](administration/reply_by_email.md) Allow users to comment on issues and merge requests by replying to notification emails.
- [Migrate DoggoHub CI to CE/EE](migrate_ci_to_ce/README.md) Follow this guide to migrate your existing DoggoHub CI data to DoggoHub CE/EE.
- [Git LFS configuration](workflow/lfs/lfs_administration.md)
- [Housekeeping](administration/housekeeping.md) Keep your Git repository tidy and fast.
- [DoggoHub Performance Monitoring](administration/monitoring/performance/introduction.md) Configure DoggoHub and InfluxDB for measuring performance metrics.
- [Request Profiling](administration/monitoring/performance/request_profiling.md) Get a detailed profile on slow requests.
- [Monitoring uptime](user/admin_area/monitoring/health_check.md) Check the server status using the health check endpoint.
- [Debugging Tips](administration/troubleshooting/debug.md) Tips to debug problems when things go wrong
- [Sidekiq Troubleshooting](administration/troubleshooting/sidekiq.md) Debug when Sidekiq appears hung and is not processing jobs.
- [High Availability](administration/high_availability/README.md) Configure multiple servers for scaling or high availability.
- [Container Registry](administration/container_registry.md) Configure Docker Registry with DoggoHub.
- [Multiple mountpoints for the repositories storage](administration/repository_storages.md) Define multiple repository storage paths to distribute the storage load.

## Contributor documentation

- [Development](development/README.md) All styleguides and explanations how to contribute.
- [Legal](legal/README.md) Contributor license agreements.
