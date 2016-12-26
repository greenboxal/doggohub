# rubocop:disable all
class AddIssuesTrackerToProject < ActiveRecord::Migration
  def change
    add_column :projects, :issues_tracker, :string, default: :doggohub, null: false
  end
end
