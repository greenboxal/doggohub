# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class AddProtectedBranchesMergeAccess < ActiveRecord::Migration
  DOWNTIME = false

  def change
    create_table :protected_branch_merge_access_levels do |t|
      t.references :protected_branch, index: { name: "index_protected_branch_merge_access" }, foreign_key: true, null: false

      # Gitlab::Access::MASTER == 40
      t.integer :access_level, default: 40, null: false

      t.timestamps null: false
    end
  end
end
