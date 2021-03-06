# Be sure to restart your server when you modify this file.

require 'doggohub/current_settings'
include Gitlab::CurrentSettings

# allow it to fail: it may do so when create_from_defaults is executed before migrations are actually done
begin
  Settings.doggohub['session_expire_delay'] = current_application_settings.session_expire_delay || 10080
rescue
  Settings.doggohub['session_expire_delay'] ||= 10080
end

if Rails.env.test?
  Gitlab::Application.config.session_store :cookie_store, key: "_doggohub_session"
else
  redis_config = Gitlab::Redis.params
  redis_config[:namespace] = Gitlab::Redis::SESSION_NAMESPACE

  Gitlab::Application.config.session_store(
    :redis_store, # Using the cookie_store would enable session replay attacks.
    servers: redis_config,
    key: '_doggohub_session',
    secure: Gitlab.config.doggohub.https,
    httponly: true,
    expires_in: Settings.doggohub['session_expire_delay'] * 60,
    path: Rails.application.config.relative_url_root.nil? ? '/' : Gitlab::Application.config.relative_url_root
  )
end
