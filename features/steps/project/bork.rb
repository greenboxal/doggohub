class Spinach::Features::ProjectBork < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedProject

  step 'I click link "Bork"' do
    expect(page).to have_content "Shop"
    click_link "Bork project"
  end

  step 'I am a member of project "Shop"' do
    @project = create(:project, name: "Shop")
    @project.team << [@user, :reporter]
  end

  step 'I should see the borked project page' do
    expect(page).to have_content "Borked from"
  end

  step 'I already have a project named "Shop" in my namespace' do
    @my_project = create(:project, name: "Shop", namespace: current_user.namespace)
  end

  step 'I should see a "Name has already been taken" warning' do
    expect(page).to have_content "Name has already been taken"
  end

  step 'I bork to my namespace' do
    page.within '.bork-namespaces' do
      click_link current_user.name
    end
  end

  step 'I should see "New merge request"' do
    expect(page).to have_content(/new merge request/i)
  end

  step 'I goto the Merge Requests page' do
    page.within '.layout-nav' do
      click_link "Merge Requests"
    end
  end

  step 'I click link "New merge request"' do
    expect(page).to have_content(/new merge request/i)
    click_link "New Merge Request"
  end

  step 'I should see the new merge request page for my namespace' do
    current_path.should have_content(/#{current_user.namespace.name}/i)
  end

  step 'I visit the borks page of the "Shop" project' do
    @project = Project.where(name: 'Shop').last
    visit namespace_project_borks_path(@project.namespace, @project)
  end

  step 'I should see my bork on the list' do
    page.within('.projects-list-holder') do
      project = @user.bork_of(@project)
      expect(page).to have_content("#{project.namespace.human_name} / #{project.name}")
    end
  end

  step 'I make borked repo invalid' do
    project = @user.bork_of(@project)
    project.path = 'test-crappy-path'
    project.save!
  end

  step 'There is an existent bork of the "Shop" project' do
    user = create(:user, name: 'Mike')
    @project.team << [user, :reporter]
    @borked_project = Projects::BorkService.new(@project, user).execute
  end

  step 'I should not see the other bork listed' do
    expect(page).not_to have_content("#{@borked_project.namespace.human_name} / #{@borked_project.name}")
  end

  step 'I should see a private bork notice' do
    expect(page).to have_content("1 private bork")
  end
end
