# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class AddUniqueIndexForEnvironmentSlug < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = true
  DOWNTIME_REASON = 'Adding a *unique* index to environments.slug'

  disable_ddl_transaction!

  def change
    add_concurrent_index :environments, [:project_id, :slug], unique: true
  end
end
