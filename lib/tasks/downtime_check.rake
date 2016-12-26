desc 'Checks if migrations in a branch require downtime'
task downtime_check: :environment do
  if defined?(Gitlab::License)
    repo = 'doggohub-ee'
  else
    repo = 'doggohub-ce'
  end

  `git fetch https://doggohub.com/doggohub-org/#{repo}.git --depth 1`

  Rake::Task['doggohub:db:downtime_check'].invoke('FETCH_HEAD')
end
