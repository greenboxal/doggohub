require 'spec_helper'

describe BuildkiteService, models: true do
  describe 'Associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to have_one :service_hook }
  end

  describe 'Validations' do
    context 'when service is active' do
      before { subject.active = true }

      it { is_expected.to validate_presence_of(:project_url) }
      it { is_expected.to validate_presence_of(:token) }
      it_behaves_like 'issue tracker service URL attribute', :project_url
    end

    context 'when service is inactive' do
      before { subject.active = false }

      it { is_expected.not_to validate_presence_of(:project_url) }
      it { is_expected.not_to validate_presence_of(:token) }
    end
  end

  describe 'commits methods' do
    before do
      @project = Project.new
      allow(@project).to receive(:default_branch).and_return('default-brancho')

      @service = BuildkiteService.new
      allow(@service).to receive_messages(
        project: @project,
        service_hook: true,
        project_url: 'https://buildkite.com/account-name/example-project',
        token: 'secret-sauce-webhook-token:secret-sauce-status-token'
      )
    end

    describe '#webhook_url' do
      it 'returns the webhook url' do
        expect(@service.webhook_url).to eq(
          'https://webhook.buildkite.com/deliver/secret-sauce-webhook-token'
        )
      end
    end

    describe '#commit_status_path' do
      it 'returns the correct status page' do
        expect(@service.commit_status_path('2ab7834c')).to eq(
          'https://doggohub.buildkite.com/status/secret-sauce-status-token.json?commit=2ab7834c'
        )
      end
    end

    describe '#build_page' do
      it 'returns the correct build page' do
        expect(@service.build_page('2ab7834c', nil)).to eq(
          'https://buildkite.com/account-name/example-project/builds?commit=2ab7834c'
        )
      end
    end
  end
end
