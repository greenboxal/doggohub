# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class AddStartDateToMilestones < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :milestones, :start_date, :date
  end
end
