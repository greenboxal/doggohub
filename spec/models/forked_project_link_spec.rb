require 'spec_helper'

describe BorkedProjectLink, "add link on bork" do
  let(:project_from) { create(:project) }
  let(:namespace) { create(:namespace) }
  let(:user) { create(:user, namespace: namespace) }

  before do
    create(:project_member, :reporter, user: user, project: project_from)
    @project_to = bork_project(project_from, user)
  end

  it "project_to knows it is borked" do
    expect(@project_to.borked?).to be_truthy
  end

  it "project knows who it is borked from" do
    expect(@project_to.borked_from_project).to eq(project_from)
  end
end

describe '#borked?' do
  let(:borked_project_link) { build(:borked_project_link) }
  let(:project_from) { create(:project) }
  let(:project_to) { create(:project, borked_project_link: borked_project_link) }

  before :each do
    borked_project_link.borked_from_project = project_from
    borked_project_link.borked_to_project = project_to
    borked_project_link.save!
  end

  it "project_to knows it is borked" do
    expect(project_to.borked?).to be_truthy
  end

  it "project_from is not borked" do
    expect(project_from.borked?).to be_falsey
  end

  it "project_to.destroy destroys bork_link" do
    expect(borked_project_link).to receive(:destroy)
    project_to.destroy
  end
end

def bork_project(from_project, user)
  shell = double('doggohub_shell', bork_repository: true)

  service = Projects::BorkService.new(from_project, user)
  allow(service).to receive(:doggohub_shell).and_return(shell)

  service.execute
end
