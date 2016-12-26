require 'rake_helper'

describe 'doggohub:ldap:rename_provider rake task' do
  it 'completes without error' do
    Rake.application.rake_require 'tasks/doggohub/ldap'
    stub_warn_user_is_not_doggohub
    ENV['force'] = 'yes'

    create(:identity) # Necessary to prevent `exit 1` from the task.

    run_rake_task('doggohub:ldap:rename_provider', 'ldapmain', 'ldapfoo')
  end
end
