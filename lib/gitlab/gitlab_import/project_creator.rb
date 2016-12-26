module Gitlab
  module GitlabImport
    class ProjectCreator
      attr_reader :repo, :namespace, :current_user, :session_data

      def initialize(repo, namespace, current_user, session_data)
        @repo = repo
        @namespace = namespace
        @current_user = current_user
        @session_data = session_data
      end

      def execute
        ::Projects::CreateService.new(
          current_user,
          name: repo["name"],
          path: repo["path"],
          description: repo["description"],
          namespace_id: namespace.id,
          visibility_level: repo["visibility_level"],
          import_type: "doggohub",
          import_source: repo["path_with_namespace"],
          import_url: repo["http_url_to_repo"].sub("://", "://oauth2:#{@session_data[:doggohub_access_token]}@")
        ).execute
      end
    end
  end
end
