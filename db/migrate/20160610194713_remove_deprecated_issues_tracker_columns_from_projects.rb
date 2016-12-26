class RemoveDeprecatedIssuesTrackerColumnsFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :issues_tracker, :string, default: 'doggohub', null: false
    remove_column :projects, :issues_tracker_id, :string
  end
end
