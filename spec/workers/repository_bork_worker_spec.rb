require 'spec_helper'

describe RepositoryBorkWorker do
  let(:project) { create(:project) }
  let(:bork_project) { create(:project, borked_from_project: project) }
  let(:shell) { Gitlab::Shell.new }

  subject { RepositoryBorkWorker.new }

  before do
    allow(subject).to receive(:doggohub_shell).and_return(shell)
  end

  describe "#perform" do
    it "creates a new repository from a bork" do
      expect(shell).to receive(:bork_repository).with(
        '/test/path',
        project.path_with_namespace,
        project.repository_storage_path,
        bork_project.namespace.path
      ).and_return(true)

      subject.perform(
        project.id,
        '/test/path',
        project.path_with_namespace,
        bork_project.namespace.path)
    end

    it 'flushes various caches' do
      expect(shell).to receive(:bork_repository).with(
        '/test/path',
        project.path_with_namespace,
        project.repository_storage_path,
        bork_project.namespace.path
      ).and_return(true)

      expect_any_instance_of(Repository).to receive(:expire_emptiness_caches).
        and_call_original

      expect_any_instance_of(Repository).to receive(:expire_exists_cache).
        and_call_original

      subject.perform(project.id, '/test/path', project.path_with_namespace,
                      bork_project.namespace.path)
    end

    it "handles bad bork" do
      expect(shell).to receive(:bork_repository).and_return(false)

      expect(subject.logger).to receive(:error)

      subject.perform(
        project.id,
        '/test/path',
        project.path_with_namespace,
        bork_project.namespace.path)
    end
  end
end
