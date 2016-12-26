unless Rails.env.production?
  namespace :lint do
    desc "DoggoHub | lint | Lint JavaScript files using ESLint"
    task :javascript do
      Rake::Task['eslint'].invoke
    end
  end
end

