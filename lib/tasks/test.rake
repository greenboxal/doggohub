Rake::Task["test"].clear

desc "DoggoHub | Run all tests"
task :test do
  Rake::Task["doggohub:test"].invoke
end

unless Rails.env.production?
  desc "DoggoHub | Run all tests on CI with simplecov"
  task test_ci: [:rubocop, :brakeman, :teaspoon, :spinach, :spec]
end
