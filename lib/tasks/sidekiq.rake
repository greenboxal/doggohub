namespace :sidekiq do
  desc "DoggoHub | Stop sidekiq"
  task :stop do
    system *%W(bin/background_jobs stop)
  end

  desc "DoggoHub | Start sidekiq"
  task :start do
    system *%W(bin/background_jobs start)
  end

  desc 'DoggoHub | Restart sidekiq'
  task :restart do
    system *%W(bin/background_jobs restart)
  end

  desc "DoggoHub | Start sidekiq with launchd on Mac OS X"
  task :launchd do
    system *%W(bin/background_jobs start_no_deamonize)
  end
end
