unless Rails.env.production?
  desc "DoggoHub | Run ESLint"
  task :eslint do
    system("npm", "run", "eslint")
  end
end

