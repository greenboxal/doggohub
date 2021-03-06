require 'spec_helper'

describe 'Auto deploy' do
  include WaitForAjax

  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    project.create_kubernetes_service(
      active: true,
      properties: {
        namespace: project.path,
        api_url: 'https://kubernetes.example.com',
        token: 'a' * 40,
      }
    )
    project.team << [user, :master]
    login_as user
  end

  context 'when no deployment service is active' do
    before do
      project.kubernetes_service.update!(active: false)
    end

    it 'does not show a button to set up auto deploy' do
      visit namespace_project_path(project.namespace, project)
      expect(page).to have_no_content('Set up autodeploy')
    end
  end

  context 'when a deployment service is active' do
    before do
      project.kubernetes_service.update!(active: true)
      visit namespace_project_path(project.namespace, project)
    end

    it 'shows a button to set up auto deploy' do
      expect(page).to have_link('Set up autodeploy')
    end

    it 'includes Kubernetes as an available template', js: true do
      click_link 'Set up autodeploy'
      click_button 'Choose a DoggoHub CI Yaml template'

      within '.doggohub-ci-yml-selector' do
        expect(page).to have_content('OpenShift')
      end
    end

    it 'creates a merge request using "autodeploy" branch', js: true do
      click_link 'Set up autodeploy'
      click_button 'Choose a DoggoHub CI Yaml template'
      within '.doggohub-ci-yml-selector' do
        click_on 'OpenShift'
      end
      wait_for_ajax
      click_button 'Commit Changes'

      expect(page).to have_content('New Merge Request From autodeploy into master')
    end
  end
end
