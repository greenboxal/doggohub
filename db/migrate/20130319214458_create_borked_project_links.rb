# rubocop:disable all
class CreateBorkedProjectLinks < ActiveRecord::Migration
  DOWNTIME = false

  def change
    create_table :borked_project_links do |t|
      t.integer :borked_to_project_id, null: false
      t.integer :borked_from_project_id, null: false

      t.timestamps null: true
    end
    add_index :borked_project_links, :borked_to_project_id, unique: true
  end
end
