require 'spec_helper'
require 'rake'

describe 'doggohub:mail_google_schema_whitelisting rake task' do
  before :all do
    Rake.application.rake_require "tasks/doggohub/helpers"
    Rake.application.rake_require "tasks/doggohub/mail_google_schema_whitelisting"
    # empty task as env is already loaded
    Rake::Task.define_task :environment
  end

  describe 'call' do
    before do
      # avoid writing task output to spec progress
      allow($stdout).to receive :write
    end

    let :run_rake_task do
      Rake::Task["doggohub:mail_google_schema_whitelisting"].reenable
      Rake.application.invoke_task "doggohub:mail_google_schema_whitelisting"
    end

    it 'should run the task without errors' do
      expect { run_rake_task }.not_to raise_error
    end
  end
end
