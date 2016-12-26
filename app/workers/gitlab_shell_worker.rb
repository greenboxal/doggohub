class GitlabShellWorker
  include Sidekiq::Worker
  include Gitlab::ShellAdapter
  include DedicatedSidekiqQueue

  def perform(action, *arg)
    doggohub_shell.send(action, *arg)
  end
end
