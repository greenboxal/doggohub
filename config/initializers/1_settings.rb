require_dependency Rails.root.join('lib/doggohub') # Load Gitlab as soon as possible

class Settings < Settingslogic
  source ENV.fetch('DOGGOHUB_CONFIG') { "#{Rails.root}/config/doggohub.yml" }
  namespace Rails.env

  class << self
    def doggohub_on_standard_port?
      doggohub.port.to_i == (doggohub.https ? 443 : 80)
    end

    def host_without_www(url)
      host(url).sub('www.', '')
    end

    def build_doggohub_ci_url
      if doggohub_on_standard_port?
        custom_port = nil
      else
        custom_port = ":#{doggohub.port}"
      end
      [ doggohub.protocol,
        "://",
        doggohub.host,
        custom_port,
        doggohub.relative_url_root
      ].join('')
    end

    def build_doggohub_shell_ssh_path_prefix
      user_host = "#{doggohub_shell.ssh_user}@#{doggohub_shell.ssh_host}"

      if doggohub_shell.ssh_port != 22
        "ssh://#{user_host}:#{doggohub_shell.ssh_port}/"
      else
        if doggohub_shell.ssh_host.include? ':'
          "[#{user_host}]:"
        else
          "#{user_host}:"
        end
      end
    end

    def build_base_doggohub_url
      base_doggohub_url.join('')
    end

    def build_doggohub_url
      (base_doggohub_url + [doggohub.relative_url_root]).join('')
    end

    # check that values in `current` (string or integer) is a contant in `modul`.
    def verify_constant_array(modul, current, default)
      values = default || []
      unless current.nil?
        values = []
        current.each do |constant|
          values.push(verify_constant(modul, constant, nil))
        end
        values.delete_if { |value| value.nil? }
      end
      values
    end

    # check that `current` (string or integer) is a contant in `modul`.
    def verify_constant(modul, current, default)
      constant = modul.constants.find{ |name| modul.const_get(name) == current }
      value = constant.nil? ? default : modul.const_get(constant)
      if current.is_a? String
        value = modul.const_get(current.upcase) rescue default
      end
      value
    end

    private

    def base_doggohub_url
      custom_port = doggohub_on_standard_port? ? nil : ":#{doggohub.port}"
      [ doggohub.protocol,
        "://",
        doggohub.host,
        custom_port
      ]
    end

    # Extract the host part of the given +url+.
    def host(url)
      url = url.downcase
      url = "http://#{url}" unless url.start_with?('http')

      # Get rid of the path so that we don't even have to encode it
      url_without_path = url.sub(%r{(https?://[^\/]+)/?.*}, '\1')

      URI.parse(url_without_path).host
    end
  end
end

# Default settings
Settings['ldap'] ||= Settingslogic.new({})
Settings.ldap['enabled'] = false if Settings.ldap['enabled'].nil?

# backwards compatibility, we only have one host
if Settings.ldap['enabled'] || Rails.env.test?
  if Settings.ldap['host'].present?
    # We detected old LDAP configuration syntax. Update the config to make it
    # look like it was entered with the new syntax.
    server = Settings.ldap.except('sync_time')
    Settings.ldap['servers'] = {
      'main' => server
    }
  end

  Settings.ldap['servers'].each do |key, server|
    server['label'] ||= 'LDAP'
    server['timeout'] ||= 10.seconds
    server['block_auto_created_users'] = false if server['block_auto_created_users'].nil?
    server['allow_username_or_email_login'] = false if server['allow_username_or_email_login'].nil?
    server['active_directory'] = true if server['active_directory'].nil?
    server['attributes'] = {} if server['attributes'].nil?
    server['provider_name'] ||= "ldap#{key}".downcase
    server['provider_class'] = OmniAuth::Utils.camelize(server['provider_name'])
  end
end

Settings['omniauth'] ||= Settingslogic.new({})
Settings.omniauth['enabled'] = false if Settings.omniauth['enabled'].nil?
Settings.omniauth['auto_sign_in_with_provider'] = false if Settings.omniauth['auto_sign_in_with_provider'].nil?
Settings.omniauth['allow_single_sign_on'] = false if Settings.omniauth['allow_single_sign_on'].nil?
Settings.omniauth['external_providers'] = [] if Settings.omniauth['external_providers'].nil?
Settings.omniauth['block_auto_created_users'] = true if Settings.omniauth['block_auto_created_users'].nil?
Settings.omniauth['auto_link_ldap_user'] = false if Settings.omniauth['auto_link_ldap_user'].nil?
Settings.omniauth['auto_link_saml_user'] = false if Settings.omniauth['auto_link_saml_user'].nil?

Settings.omniauth['providers'] ||= []
Settings.omniauth['cas3'] ||= Settingslogic.new({})
Settings.omniauth.cas3['session_duration'] ||= 8.hours
Settings.omniauth['session_tickets'] ||= Settingslogic.new({})
Settings.omniauth.session_tickets['cas3'] = 'ticket'

# Fill out omniauth-doggohub settings. It is needed for easy set up GHE or GH by just specifying url.

github_default_url = "https://github.com"
github_settings = Settings.omniauth['providers'].find { |provider| provider["name"] == "github" }

if github_settings
  # For compatibility with old config files (before 7.8)
  # where people dont have url in github settings
  if github_settings['url'].blank?
    github_settings['url'] = github_default_url
  end

  github_settings["args"] ||= Settingslogic.new({})

  if github_settings["url"].include?(github_default_url)
    github_settings["args"]["client_options"] = OmniAuth::Strategies::GitHub.default_options[:client_options]
  else
    github_settings["args"]["client_options"] = {
      "site"          => File.join(github_settings["url"], "api/v3"),
      "authorize_url" => File.join(github_settings["url"], "login/oauth/authorize"),
      "token_url"     => File.join(github_settings["url"], "login/oauth/access_token")
    }
  end
end

Settings['shared'] ||= Settingslogic.new({})
Settings.shared['path'] = File.expand_path(Settings.shared['path'] || "shared", Rails.root)

Settings['issues_tracker'] ||= {}

#
# DoggoHub
#
Settings['doggohub'] ||= Settingslogic.new({})
Settings.doggohub['default_projects_limit'] ||= 10
Settings.doggohub['default_branch_protection'] ||= 2
Settings.doggohub['default_can_create_group'] = true if Settings.doggohub['default_can_create_group'].nil?
Settings.doggohub['default_theme'] = Gitlab::Themes::APPLICATION_DEFAULT if Settings.doggohub['default_theme'].nil?
Settings.doggohub['host']       ||= ENV['DOGGOHUB_HOST'] || 'localhost'
Settings.doggohub['ssh_host']   ||= Settings.doggohub.host
Settings.doggohub['https']        = false if Settings.doggohub['https'].nil?
Settings.doggohub['port']       ||= Settings.doggohub.https ? 443 : 80
Settings.doggohub['relative_url_root'] ||= ENV['RAILS_RELATIVE_URL_ROOT'] || ''
Settings.doggohub['protocol'] ||= Settings.doggohub.https ? "https" : "http"
Settings.doggohub['email_enabled'] ||= true if Settings.doggohub['email_enabled'].nil?
Settings.doggohub['email_from'] ||= ENV['DOGGOHUB_EMAIL_FROM'] || "doggohub@#{Settings.doggohub.host}"
Settings.doggohub['email_display_name'] ||= ENV['DOGGOHUB_EMAIL_DISPLAY_NAME'] || 'DoggoHub'
Settings.doggohub['email_reply_to'] ||= ENV['DOGGOHUB_EMAIL_REPLY_TO'] || "noreply@#{Settings.doggohub.host}"
Settings.doggohub['email_subject_suffix'] ||= ENV['DOGGOHUB_EMAIL_SUBJECT_SUFFIX'] || ""
Settings.doggohub['base_url']   ||= Settings.send(:build_base_doggohub_url)
Settings.doggohub['url']        ||= Settings.send(:build_doggohub_url)
Settings.doggohub['user']       ||= 'git'
Settings.doggohub['user_home']  ||= begin
  Etc.getpwnam(Settings.doggohub['user']).dir
rescue ArgumentError # no user configured
  '/home/' + Settings.doggohub['user']
end
Settings.doggohub['time_zone'] ||= nil
Settings.doggohub['signup_enabled'] ||= true if Settings.doggohub['signup_enabled'].nil?
Settings.doggohub['signin_enabled'] ||= true if Settings.doggohub['signin_enabled'].nil?
Settings.doggohub['restricted_visibility_levels'] = Settings.send(:verify_constant_array, Gitlab::VisibilityLevel, Settings.doggohub['restricted_visibility_levels'], [])
Settings.doggohub['username_changing_enabled'] = true if Settings.doggohub['username_changing_enabled'].nil?
Settings.doggohub['issue_closing_pattern'] = '((?:[Cc]los(?:e[sd]?|ing)|[Ff]ix(?:e[sd]|ing)?|[Rr]esolv(?:e[sd]?|ing))(:?) +(?:(?:issues? +)?%{issue_ref}(?:(?:, *| +and +)?)|([A-Z][A-Z0-9_]+-\d+))+)' if Settings.doggohub['issue_closing_pattern'].nil?
Settings.doggohub['default_projects_features'] ||= {}
Settings.doggohub['webhook_timeout'] ||= 10
Settings.doggohub['max_attachment_size'] ||= 10
Settings.doggohub['session_expire_delay'] ||= 10080
Settings.doggohub.default_projects_features['issues']             = true if Settings.doggohub.default_projects_features['issues'].nil?
Settings.doggohub.default_projects_features['merge_requests']     = true if Settings.doggohub.default_projects_features['merge_requests'].nil?
Settings.doggohub.default_projects_features['wiki']               = true if Settings.doggohub.default_projects_features['wiki'].nil?
Settings.doggohub.default_projects_features['snippets']           = false if Settings.doggohub.default_projects_features['snippets'].nil?
Settings.doggohub.default_projects_features['builds']             = true if Settings.doggohub.default_projects_features['builds'].nil?
Settings.doggohub.default_projects_features['container_registry'] = true if Settings.doggohub.default_projects_features['container_registry'].nil?
Settings.doggohub.default_projects_features['visibility_level']   = Settings.send(:verify_constant, Gitlab::VisibilityLevel, Settings.doggohub.default_projects_features['visibility_level'], Gitlab::VisibilityLevel::PRIVATE)
Settings.doggohub['domain_whitelist'] ||= []
Settings.doggohub['import_sources'] ||= %w[github bitbucket doggohub google_code fogbugz git doggohub_project gitea]
Settings.doggohub['trusted_proxies'] ||= []
Settings.doggohub['no_todos_messages'] ||= YAML.load_file(Rails.root.join('config', 'no_todos_messages.yml'))

#
# CI
#
Settings['doggohub_ci'] ||= Settingslogic.new({})
Settings.doggohub_ci['shared_runners_enabled'] = true if Settings.doggohub_ci['shared_runners_enabled'].nil?
Settings.doggohub_ci['all_broken_builds']     = true if Settings.doggohub_ci['all_broken_builds'].nil?
Settings.doggohub_ci['add_pusher']            = false if Settings.doggohub_ci['add_pusher'].nil?
Settings.doggohub_ci['builds_path']           = File.expand_path(Settings.doggohub_ci['builds_path'] || "builds/", Rails.root)
Settings.doggohub_ci['url']                 ||= Settings.send(:build_doggohub_ci_url)

#
# Reply by email
#
Settings['incoming_email'] ||= Settingslogic.new({})
Settings.incoming_email['enabled'] = false if Settings.incoming_email['enabled'].nil?

#
# Build Artifacts
#
Settings['artifacts'] ||= Settingslogic.new({})
Settings.artifacts['enabled']      = true if Settings.artifacts['enabled'].nil?
Settings.artifacts['path']         = File.expand_path(Settings.artifacts['path'] || File.join(Settings.shared['path'], "artifacts"), Rails.root)
Settings.artifacts['max_size']   ||= 100 # in megabytes

#
# Registry
#
Settings['registry'] ||= Settingslogic.new({})
Settings.registry['enabled']       ||= false
Settings.registry['host']          ||= "example.com"
Settings.registry['port']          ||= nil
Settings.registry['api_url']       ||= "http://localhost:5000/"
Settings.registry['key']           ||= nil
Settings.registry['issuer']        ||= nil
Settings.registry['host_port']     ||= [Settings.registry['host'], Settings.registry['port']].compact.join(':')
Settings.registry['path']            = File.expand_path(Settings.registry['path'] || File.join(Settings.shared['path'], 'registry'), Rails.root)

#
# Git LFS
#
Settings['lfs'] ||= Settingslogic.new({})
Settings.lfs['enabled']      = true if Settings.lfs['enabled'].nil?
Settings.lfs['storage_path'] = File.expand_path(Settings.lfs['storage_path'] || File.join(Settings.shared['path'], "lfs-objects"), Rails.root)

#
# Mattermost
#
Settings['mattermost'] ||= Settingslogic.new({})
Settings.mattermost['enabled'] = false if Settings.mattermost['enabled'].nil?
Settings.mattermost['host'] = nil unless Settings.mattermost.enabled

#
# Gravatar
#
Settings['gravatar'] ||= Settingslogic.new({})
Settings.gravatar['enabled']      = true if Settings.gravatar['enabled'].nil?
Settings.gravatar['plain_url']  ||= 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
Settings.gravatar['ssl_url']    ||= 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
Settings.gravatar['host']         = Settings.host_without_www(Settings.gravatar['plain_url'])

#
# Cron Jobs
#
Settings['cron_jobs'] ||= Settingslogic.new({})
Settings.cron_jobs['stuck_ci_builds_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['stuck_ci_builds_worker']['cron'] ||= '0 0 * * *'
Settings.cron_jobs['stuck_ci_builds_worker']['job_class'] = 'StuckCiBuildsWorker'
Settings.cron_jobs['expire_build_artifacts_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['expire_build_artifacts_worker']['cron'] ||= '50 * * * *'
Settings.cron_jobs['expire_build_artifacts_worker']['job_class'] = 'ExpireBuildArtifactsWorker'
Settings.cron_jobs['repository_check_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['repository_check_worker']['cron'] ||= '20 * * * *'
Settings.cron_jobs['repository_check_worker']['job_class'] = 'RepositoryCheck::BatchWorker'
Settings.cron_jobs['admin_email_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['admin_email_worker']['cron'] ||= '0 0 * * 0'
Settings.cron_jobs['admin_email_worker']['job_class'] = 'AdminEmailWorker'
Settings.cron_jobs['repository_archive_cache_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['repository_archive_cache_worker']['cron'] ||= '0 * * * *'
Settings.cron_jobs['repository_archive_cache_worker']['job_class'] = 'RepositoryArchiveCacheWorker'
Settings.cron_jobs['import_export_project_cleanup_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['import_export_project_cleanup_worker']['cron'] ||= '0 * * * *'
Settings.cron_jobs['import_export_project_cleanup_worker']['job_class'] = 'ImportExportProjectCleanupWorker'
Settings.cron_jobs['requests_profiles_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['requests_profiles_worker']['cron'] ||= '0 0 * * *'
Settings.cron_jobs['requests_profiles_worker']['job_class'] = 'RequestsProfilesWorker'
Settings.cron_jobs['remove_expired_members_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['remove_expired_members_worker']['cron'] ||= '10 0 * * *'
Settings.cron_jobs['remove_expired_members_worker']['job_class'] = 'RemoveExpiredMembersWorker'
Settings.cron_jobs['remove_expired_group_links_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['remove_expired_group_links_worker']['cron'] ||= '10 0 * * *'
Settings.cron_jobs['remove_expired_group_links_worker']['job_class'] = 'RemoveExpiredGroupLinksWorker'
Settings.cron_jobs['prune_old_events_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['prune_old_events_worker']['cron'] ||= '0 */6 * * *'
Settings.cron_jobs['prune_old_events_worker']['job_class'] = 'PruneOldEventsWorker'

Settings.cron_jobs['trending_projects_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['trending_projects_worker']['cron'] = '0 1 * * *'
Settings.cron_jobs['trending_projects_worker']['job_class'] = 'TrendingProjectsWorker'
Settings.cron_jobs['remove_unreferenced_lfs_objects_worker'] ||= Settingslogic.new({})
Settings.cron_jobs['remove_unreferenced_lfs_objects_worker']['cron'] ||= '20 0 * * *'
Settings.cron_jobs['remove_unreferenced_lfs_objects_worker']['job_class'] = 'RemoveUnreferencedLfsObjectsWorker'

#
# DoggoHub Shell
#
Settings['doggohub_shell'] ||= Settingslogic.new({})
Settings.doggohub_shell['path']         ||= Settings.doggohub['user_home'] + '/doggohub-shell/'
Settings.doggohub_shell['hooks_path']   ||= Settings.doggohub['user_home'] + '/doggohub-shell/hooks/'
Settings.doggohub_shell['secret_file'] ||= Rails.root.join('.doggohub_shell_secret')
Settings.doggohub_shell['receive_pack']   = true if Settings.doggohub_shell['receive_pack'].nil?
Settings.doggohub_shell['upload_pack']    = true if Settings.doggohub_shell['upload_pack'].nil?
Settings.doggohub_shell['ssh_host']     ||= Settings.doggohub.ssh_host
Settings.doggohub_shell['ssh_port']     ||= 22
Settings.doggohub_shell['ssh_user']     ||= Settings.doggohub.user
Settings.doggohub_shell['owner_group']  ||= Settings.doggohub.user
Settings.doggohub_shell['ssh_path_prefix'] ||= Settings.send(:build_doggohub_shell_ssh_path_prefix)

#
# Repositories
#
Settings['repositories'] ||= Settingslogic.new({})
Settings.repositories['storages'] ||= {}
# Setting doggohub_shell.repos_path is DEPRECATED and WILL BE REMOVED in version 9.0
Settings.repositories.storages['default'] ||= Settings.doggohub_shell['repos_path'] || Settings.doggohub['user_home'] + '/repositories/'

#
# The repository_downloads_path is used to remove outdated repository
# archives, if someone has it configured incorrectly, and it points
# to the path where repositories are stored this can cause some
# data-integrity issue. In this case, we sets it to the default
# repository_downloads_path value.
#
repositories_storages_path     = Settings.repositories.storages.values
repository_downloads_path      = Settings.doggohub['repository_downloads_path'].to_s.gsub(/\/$/, '')
repository_downloads_full_path = File.expand_path(repository_downloads_path, Settings.doggohub['user_home'])

if repository_downloads_path.blank? || repositories_storages_path.any? { |path| [repository_downloads_path, repository_downloads_full_path].include?(path.gsub(/\/$/, '')) }
  Settings.doggohub['repository_downloads_path'] = File.join(Settings.shared['path'], 'cache/archive')
end

#
# Backup
#
Settings['backup'] ||= Settingslogic.new({})
Settings.backup['keep_time']  ||= 0
Settings.backup['pg_schema']    = nil
Settings.backup['path']         = File.expand_path(Settings.backup['path'] || "tmp/backups/", Rails.root)
Settings.backup['archive_permissions'] ||= 0600
Settings.backup['upload'] ||= Settingslogic.new({ 'remote_directory' => nil, 'connection' => nil })
# Convert upload connection settings to use symbol keys, to make Fog happy
if Settings.backup['upload']['connection']
  Settings.backup['upload']['connection'] = Hash[Settings.backup['upload']['connection'].map { |k, v| [k.to_sym, v] }]
end
Settings.backup['upload']['multipart_chunk_size'] ||= 104857600
Settings.backup['upload']['encryption'] ||= nil

#
# Git
#
Settings['git'] ||= Settingslogic.new({})
Settings.git['max_size']  ||= 20971520 # 20.megabytes
Settings.git['bin_path']  ||= '/usr/bin/git'
Settings.git['timeout']   ||= 10

# Important: keep the satellites.path setting until DoggoHub 9.0 at
# least. This setting is fed to 'rm -rf' in
# db/migrate/20151023144219_remove_satellites.rb
Settings['satellites'] ||= Settingslogic.new({})
Settings.satellites['path'] = File.expand_path(Settings.satellites['path'] || "tmp/repo_satellites/", Rails.root)

#
# Extra customization
#
Settings['extra'] ||= Settingslogic.new({})

#
# Rack::Attack settings
#
Settings['rack_attack'] ||= Settingslogic.new({})
Settings.rack_attack['git_basic_auth'] ||= Settingslogic.new({})
Settings.rack_attack.git_basic_auth['enabled'] = true if Settings.rack_attack.git_basic_auth['enabled'].nil?
Settings.rack_attack.git_basic_auth['ip_whitelist'] ||= %w{127.0.0.1}
Settings.rack_attack.git_basic_auth['maxretry'] ||= 10
Settings.rack_attack.git_basic_auth['findtime'] ||= 1.minute
Settings.rack_attack.git_basic_auth['bantime'] ||= 1.hour

#
# Testing settings
#
if Rails.env.test?
  Settings.doggohub['default_projects_limit']   = 42
  Settings.doggohub['default_can_create_group'] = true
  Settings.doggohub['default_can_create_team']  = false
end

# Force a refresh of application settings at startup
begin
  ApplicationSetting.expire
  Ci::ApplicationSetting.expire
rescue
  # Gracefully handle when Redis is not available. For example,
  # omnibus may fail here during assets:precompile.
end
