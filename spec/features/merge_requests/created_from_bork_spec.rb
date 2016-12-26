require 'spec_helper'

feature 'Merge request created from bork' do
  given(:user) { create(:user) }
  given(:project) { create(:project, :public) }
  given(:bork_project) { create(:project, :public) }

  given!(:merge_request) do
    create(:borked_project_link, borked_to_project: bork_project,
                                 borked_from_project: project)

    create(:merge_request_with_diffs, source_project: bork_project,
                                      target_project: project,
                                      description: 'Test merge request')
  end

  background do
    bork_project.team << [user, :master]
    login_as user
  end

  scenario 'user can access merge request' do
    visit_merge_request(merge_request)

    expect(page).to have_content 'Test merge request'
  end

  context 'source project is deleted' do
    background do
      MergeRequests::MergeService.new(project, user).execute(merge_request)
      bork_project.destroy!
    end

    scenario 'user can access merge request' do
      visit_merge_request(merge_request)

      expect(page).to have_content 'Test merge request'
      expect(page).to have_content "(removed):#{merge_request.source_branch}"
    end
  end

  context 'pipeline present in source project' do
    given(:pipeline) do
      create(:ci_pipeline,
             project: bork_project,
             sha: merge_request.diff_head_sha,
             ref: merge_request.source_branch)
    end

    background do
      create(:ci_build, pipeline: pipeline, name: 'rspec')
      create(:ci_build, pipeline: pipeline, name: 'spinach')
    end

    scenario 'user visits a pipelines page', js: true do
      visit_merge_request(merge_request)
      page.within('.merge-request-tabs') { click_link 'Pipelines' }

      page.within('table.ci-table') do
        expect(page).to have_content pipeline.status
        expect(page).to have_content pipeline.id
      end

      expect(page.find('a.btn-remove')[:href])
        .to include bork_project.path_with_namespace
    end
  end

  def visit_merge_request(mr)
    visit namespace_project_merge_request_path(project.namespace,
                                               project, mr)
  end
end
