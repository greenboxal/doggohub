desc "DoggoHub | Setup doggohub db"
task :setup do
  Rake::Task["doggohub:setup"].invoke
end
