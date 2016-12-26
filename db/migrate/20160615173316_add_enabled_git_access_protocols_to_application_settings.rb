# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.
# rubocop:disable all

class AddEnabledGitAccessProtocolsToApplicationSettings < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  def change
    add_column :application_settings, :enabled_git_access_protocol, :string
  end
end
