desc 'Checks if the branch would apply cleanly to EE'
task ee_compat_check: :environment do
  Rake::Task['doggohub:dev:ee_compat_check'].invoke
end
