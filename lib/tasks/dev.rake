task dev: ["dev:setup"]

namespace :dev do
  desc "DoggoHub | Setup developer environment (db, fixtures)"
  task :setup => :environment do
    ENV['force'] = 'yes'
    Rake::Task["doggohub:setup"].invoke
    Rake::Task["doggohub:shell:setup"].invoke
  end

  desc 'DoggoHub | Start/restart foreman and watch for changes'
  task :foreman => :environment do
    sh 'rerun --dir app,config,lib -- foreman start'
  end
end
