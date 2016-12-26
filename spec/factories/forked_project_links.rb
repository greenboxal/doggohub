FactoryGirl.define do
  factory :borked_project_link do
    association :borked_to_project, factory: :project
    association :borked_from_project, factory: :project

    after(:create) do |link|
      link.borked_from_project.reload
      link.borked_to_project.reload
    end
  end
end
