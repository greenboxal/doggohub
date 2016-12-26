# See http://doc.doggohub.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for DoggoHub.

class AddEnvironmentToBuilds < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  def change
    add_column :ci_builds, :environment, :string
  end
end
