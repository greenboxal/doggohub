# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class AddLowerPathIndexToRoutes < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    return unless Gitlab::Database.postgresql?

    execute 'CREATE INDEX CONCURRENTLY index_on_routes_lower_path ON routes (LOWER(path));'
  end

  def down
    return unless Gitlab::Database.postgresql?

    remove_index :routes, name: :index_on_routes_lower_path
  end
end
