require 'spec_helper'

describe Projects::UnlinkBorkService, services: true do
  subject { Projects::UnlinkBorkService.new(bork_project, user) }

  let(:bork_link) { create(:borked_project_link) }
  let(:bork_project) { bork_link.borked_to_project }
  let(:user) { create(:user) }

  context 'with opened merge request on the source project' do
    let(:merge_request) { create(:merge_request, source_project: bork_project, target_project: bork_link.borked_from_project) }
    let(:mr_close_service) { MergeRequests::CloseService.new(bork_project, user) }

    before do
      allow(MergeRequests::CloseService).to receive(:new).
        with(bork_project, user).
        and_return(mr_close_service)
    end

    it 'close all pending merge requests' do
      expect(mr_close_service).to receive(:execute).with(merge_request)

      subject.execute
    end
  end

  it 'remove bork relation' do
    expect(bork_project.borked_project_link).to receive(:destroy)

    subject.execute
  end
end
