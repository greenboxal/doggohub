require 'spec_helper'

describe Gitlab::ImportSources do
  describe '.options' do
    it 'returns a hash' do
      expected =
        {
          'GitHub'        => 'github',
          'Bitbucket'     => 'bitbucket',
          'DoggoHub.com'    => 'doggohub',
          'Google Code'   => 'google_code',
          'FogBugz'       => 'fogbugz',
          'Repo by URL'   => 'git',
          'DoggoHub export' => 'doggohub_project',
          'Gitea'         => 'gitea'
        }

      expect(described_class.options).to eq(expected)
    end
  end

  describe '.values' do
    it 'returns an array' do
      expected =
        [
          'github',
          'bitbucket',
          'doggohub',
          'google_code',
          'fogbugz',
          'git',
          'doggohub_project',
          'gitea'
        ]

      expect(described_class.values).to eq(expected)
    end
  end

  describe '.importer_names' do
    it 'returns an array of importer names' do
      expected =
        [
          'github',
          'bitbucket',
          'doggohub',
          'google_code',
          'fogbugz',
          'doggohub_project',
          'gitea'
        ]

      expect(described_class.importer_names).to eq(expected)
    end
  end

  describe '.importer' do
    import_sources = {
      'github' => Gitlab::GithubImport::Importer,
      'bitbucket' => Gitlab::BitbucketImport::Importer,
      'doggohub' => Gitlab::GitlabImport::Importer,
      'google_code' => Gitlab::GoogleCodeImport::Importer,
      'fogbugz' => Gitlab::FogbugzImport::Importer,
      'git' => nil,
      'doggohub_project' => Gitlab::ImportExport::Importer,
      'gitea' => Gitlab::GithubImport::Importer
    }

    import_sources.each do |name, klass|
      it "returns #{klass} when given #{name}" do
        expect(described_class.importer(name)).to eq(klass)
      end
    end
  end

  describe '.title' do
    import_sources = {
      'github' => 'GitHub',
      'bitbucket' => 'Bitbucket',
      'doggohub' => 'DoggoHub.com',
      'google_code' => 'Google Code',
      'fogbugz' => 'FogBugz',
      'git' => 'Repo by URL',
      'doggohub_project' => 'DoggoHub export',
      'gitea' => 'Gitea'
    }

    import_sources.each do |name, title|
      it "returns #{title} when given #{name}" do
        expect(described_class.title(name)).to eq(title)
      end
    end
  end
end
