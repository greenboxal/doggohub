module Gitlab
  module Template
    class GitlabCiYmlTemplate < BaseTemplate
      def content
        explanation = "# This file is a template, and might need editing before it works on your project."
        [explanation, super].join("\n")
      end

      class << self
        def extension
          '.doggohub-ci.yml'
        end

        def categories
          {
            'General' => '',
            'Pages' => 'Pages',
            'Autodeploy' => 'autodeploy'
          }
        end

        def base_dir
          Rails.root.join('vendor/doggohub-ci-yml')
        end

        def finder(project = nil)
          Gitlab::Template::Finders::GlobalTemplateFinder.new(self.base_dir, self.extension, self.categories)
        end

        def dropdown_names(context)
          categories = context == 'autodeploy' ? ['Autodeploy'] : ['General', 'Pages']
          super().slice(*categories)
        end
      end
    end
  end
end
