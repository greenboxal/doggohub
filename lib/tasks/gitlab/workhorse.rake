namespace :doggohub do
  namespace :workhorse do
    desc "DoggoHub | Install or upgrade doggohub-workhorse"
    task :install, [:dir] => :environment do |t, args|
      warn_user_is_not_doggohub
      unless args.dir.present?
        abort %(Please specify the directory where you want to install doggohub-workhorse:\n  rake "doggohub:workhorse:install[/home/git/doggohub-workhorse]")
      end

      tag = "v#{Gitlab::Workhorse.version}"
      repo = 'https://doggohub.com/doggohub-org/doggohub-workhorse.git'

      checkout_or_clone_tag(tag: tag, repo: repo, target_dir: args.dir)

      _, status = Gitlab::Popen.popen(%w[which gmake])
      command = status.zero? ? 'gmake' : 'make'

      Dir.chdir(args.dir) do
        run_command!([command])
      end
    end
  end
end
