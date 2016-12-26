module Gitlab::ConfigHelper
  def doggohub_config_features
    Gitlab.config.doggohub.default_projects_features
  end

  def doggohub_config
    Gitlab.config.doggohub
  end
end
