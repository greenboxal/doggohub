require 'rake_helper'

describe 'doggohub:shell rake tasks' do
  before do
    Rake.application.rake_require 'tasks/doggohub/shell'

    stub_warn_user_is_not_doggohub
  end

  describe 'install task' do
    it 'invokes create_hooks task' do
      expect(Rake::Task['doggohub:shell:create_hooks']).to receive(:invoke)

      run_rake_task('doggohub:shell:install')
    end
  end

  describe 'create_hooks task' do
    it 'calls doggohub-shell bin/create_hooks' do
      expect_any_instance_of(Object).to receive(:system)
        .with("#{Gitlab.config.doggohub_shell.path}/bin/create-hooks", *repository_storage_paths_args)

      run_rake_task('doggohub:shell:create_hooks')
    end
  end
end
