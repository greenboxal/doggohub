# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class AddIncomingEmailTokenToUsers < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :users, :incoming_email_token, :string
    add_concurrent_index :users, :incoming_email_token
  end
end
