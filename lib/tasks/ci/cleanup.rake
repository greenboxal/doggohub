namespace :ci do
  namespace :cleanup do
    desc "DoggoHub CI | Clean running builds"
    task builds: :environment do
      Ci::Build.running.update_all(status: 'canceled')
    end
  end
end
