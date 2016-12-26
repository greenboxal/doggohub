# rubocop:disable all
class AddGitlabAccessTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :doggohub_access_token, :string
  end
end
