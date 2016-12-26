# rubocop:disable all
class MigrateToNewShell < ActiveRecord::Migration
  def change
    return if Rails.env.test?

    doggohub_shell_path = Gitlab.config.doggohub_shell.path
    if system("#{doggohub_shell_path}/bin/create-hooks")
      puts 'Repositories updated with new hooks'
    else
      raise 'Failed to rewrite doggohub-shell hooks in repositories'
    end
  end
end
