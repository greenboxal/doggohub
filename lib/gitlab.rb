require_dependency 'doggohub/git'

module Gitlab
  def self.com?
    # Check `staging?` as well to keep parity with doggohub.com
    Gitlab.config.doggohub.url == 'https://doggohub.com' || staging?
  end

  def self.staging?
    Gitlab.config.doggohub.url == 'https://staging.doggohub.com'
  end
end
