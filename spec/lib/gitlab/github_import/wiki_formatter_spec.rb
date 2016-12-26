require 'spec_helper'

describe Gitlab::GithubImport::WikiFormatter, lib: true do
  let(:project) do
    create(:project,
           namespace: create(:namespace, path: 'doggohubhq'),
           import_url: 'https://xxx@github.com/doggohubhq/sample.doggohubhq.git')
  end

  subject(:wiki) { described_class.new(project) }

  describe '#path_with_namespace' do
    it 'appends .wiki to project path' do
      expect(wiki.path_with_namespace).to eq 'doggohubhq/doggohubhq.wiki'
    end
  end

  describe '#import_url' do
    it 'returns URL of the wiki repository' do
      expect(wiki.import_url).to eq 'https://xxx@github.com/doggohubhq/sample.doggohubhq.wiki.git'
    end
  end
end
