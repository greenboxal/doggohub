# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class RemoveDevelopersCanPushFromProtectedBranches < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # This is only required for `#down`
  disable_ddl_transaction!

  DOWNTIME = false

  def up
    remove_column :protected_branches, :developers_can_push, :boolean
  end

  def down
    add_column_with_default(:protected_branches, :developers_can_push, :boolean, default: false, allow_null: false)
  end
end
