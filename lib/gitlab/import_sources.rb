# Gitlab::ImportSources module
#
# Define import sources that can be used
# during the creation of new project
#
module Gitlab
  module ImportSources
    extend CurrentSettings

    ImportSource = Struct.new(:name, :title, :importer)

    ImportTable = [
      ImportSource.new('github',         'GitHub',        Gitlab::GithubImport::Importer),
      ImportSource.new('bitbucket',      'Bitbucket',     Gitlab::BitbucketImport::Importer),
      ImportSource.new('doggohub',         'DoggoHub.com',    Gitlab::GitlabImport::Importer),
      ImportSource.new('google_code',    'Google Code',   Gitlab::GoogleCodeImport::Importer),
      ImportSource.new('fogbugz',        'FogBugz',       Gitlab::FogbugzImport::Importer),
      ImportSource.new('git',            'Repo by URL',   nil),
      ImportSource.new('doggohub_project', 'DoggoHub export', Gitlab::ImportExport::Importer),
      ImportSource.new('gitea',          'Gitea',         Gitlab::GithubImport::Importer)
    ].freeze

    class << self
      def options
        @options ||= Hash[ImportTable.map { |importer| [importer.title, importer.name] }]
      end

      def values
        @values ||= ImportTable.map(&:name)
      end

      def importer_names
        @importer_names ||= ImportTable.select(&:importer).map(&:name)
      end

      def importer(name)
        ImportTable.find { |import_source| import_source.name == name }.importer
      end

      def title(name)
        options.key(name)
      end
    end
  end
end
