module StubGitlabData
  def doggohub_ci_yaml
    File.read(Rails.root.join('spec/support/doggohub_stubs/doggohub_ci.yml'))
  end
end
