class ChangeSlackServiceToSlackNotificationService < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  # This migration is a no-op, as it existed in an RC but we renamed
  # SlackNotificationService back to SlackService:
  #   https://doggohub.com/doggohub-org/doggohub-ce/merge_requests/8191#note_20310845
  def change
  end
end
