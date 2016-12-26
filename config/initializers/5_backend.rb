# GIT over SSH
require_dependency Rails.root.join('lib/doggohub/backend/shell')

# DoggoHub shell adapter
require_dependency Rails.root.join('lib/doggohub/backend/shell_adapter')

required_version = Gitlab::VersionInfo.parse(Gitlab::Shell.version_required)
current_version = Gitlab::VersionInfo.parse(Gitlab::Shell.new.version)

unless current_version.valid? && required_version <= current_version
  warn "WARNING: This version of DoggoHub depends on doggohub-shell #{required_version}, but you're running #{current_version}. Please update doggohub-shell."
end
