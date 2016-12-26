default_url_options = {
  host:        Gitlab.config.doggohub.host,
  protocol:    Gitlab.config.doggohub.protocol,
  script_name: Gitlab.config.doggohub.relative_url_root
}

unless Gitlab.config.doggohub_on_standard_port?
  default_url_options[:port] = Gitlab.config.doggohub.port
end

Rails.application.routes.default_url_options = default_url_options
ActionMailer::Base.asset_host = Settings.doggohub['base_url']
