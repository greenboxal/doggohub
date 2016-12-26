require 'spec_helper'

feature 'User wants to add a .doggohub-ci.yml file', feature: true do
  include WaitForAjax

  before do
    user = create(:user)
    project = create(:project)
    project.team << [user, :master]
    login_as user
    visit namespace_project_new_blob_path(project.namespace, project, 'master', file_name: '.doggohub-ci.yml')
  end

  scenario 'user can see .doggohub-ci.yml dropdown' do
    expect(page).to have_css('.doggohub-ci-yml-selector')
  end

  scenario 'user can pick a template from the dropdown', js: true do
    find('.js-doggohub-ci-yml-selector').click
    wait_for_ajax
    within '.doggohub-ci-yml-selector' do
      find('.dropdown-input-field').set('Jekyll')
      find('.dropdown-content li', text: 'Jekyll').click
    end
    wait_for_ajax

    expect(page).to have_css('.doggohub-ci-yml-selector .dropdown-toggle-text', text: 'Jekyll')
    expect(page).to have_content('This file is a template, and might need editing before it works on your project')
    expect(page).to have_content('jekyll build -d test')
  end
end
