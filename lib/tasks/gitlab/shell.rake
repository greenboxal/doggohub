namespace :doggohub do
  namespace :shell do
    desc "DoggoHub | Install or upgrade doggohub-shell"
    task :install, [:tag, :repo] => :environment do |t, args|
      warn_user_is_not_doggohub

      default_version = Gitlab::Shell.version_required
      default_version_tag = "v#{default_version}"
      args.with_defaults(tag: default_version_tag, repo: 'https://doggohub.com/doggohub-org/doggohub-shell.git')

      doggohub_url = Gitlab.config.doggohub.url
      # doggohub-shell requires a / at the end of the url
      doggohub_url += '/' unless doggohub_url.end_with?('/')
      target_dir = Gitlab.config.doggohub_shell.path

      checkout_or_clone_tag(tag: default_version_tag, repo: args.repo, target_dir: target_dir)

      # Make sure we're on the right tag
      Dir.chdir(target_dir) do
        config = {
          user: Gitlab.config.doggohub.user,
          doggohub_url: doggohub_url,
          http_settings: {self_signed_cert: false}.stringify_keys,
          auth_file: File.join(user_home, ".ssh", "authorized_keys"),
          redis: {
            bin: %x{which redis-cli}.chomp,
            namespace: "resque:doggohub"
          }.stringify_keys,
          log_level: "INFO",
          audit_usernames: false
        }.stringify_keys

        redis_url = URI.parse(ENV['REDIS_URL'] || "redis://localhost:6379")

        if redis_url.scheme == 'unix'
          config['redis']['socket'] = redis_url.path
        else
          config['redis']['host'] = redis_url.host
          config['redis']['port'] = redis_url.port
        end

        # Generate config.yml based on existing doggohub settings
        File.open("config.yml", "w+") {|f| f.puts config.to_yaml}

        # Launch installation process
        system(*%W(bin/install) + repository_storage_paths_args)
      end

      # (Re)create hooks
      Rake::Task['doggohub:shell:create_hooks'].invoke

      # Required for debian packaging with PKGR: Setup .ssh/environment with
      # the current PATH, so that the correct ruby version gets loaded
      # Requires to set "PermitUserEnvironment yes" in sshd config (should not
      # be an issue since it is more than likely that there are no "normal"
      # user accounts on a doggohub server). The alternative is for the admin to
      # install a ruby (1.9.3+) in the global path.
      File.open(File.join(user_home, ".ssh", "environment"), "w+") do |f|
        f.puts "PATH=#{ENV['PATH']}"
      end

      Gitlab::Shell.ensure_secret_token!
    end

    desc "DoggoHub | Setup doggohub-shell"
    task setup: :environment do
      setup
    end

    desc "DoggoHub | Build missing projects"
    task build_missing_projects: :environment do
      Project.find_each(batch_size: 1000) do |project|
        path_to_repo = project.repository.path_to_repo
        if File.exist?(path_to_repo)
          print '-'
        else
          if Gitlab::Shell.new.add_repository(project.repository_storage_path,
                                              project.path_with_namespace)
            print '.'
          else
            print 'F'
          end
        end
      end
    end

    desc 'Create or repair repository hooks symlink'
    task create_hooks: :environment do
      warn_user_is_not_doggohub

      puts 'Creating/Repairing hooks symlinks for all repositories'
      system(*%W(#{Gitlab.config.doggohub_shell.path}/bin/create-hooks) + repository_storage_paths_args)
      puts 'done'.color(:green)
    end
  end

  def setup
    warn_user_is_not_doggohub

    unless ENV['force'] == 'yes'
      puts "This will rebuild an authorized_keys file."
      puts "You will lose any data stored in authorized_keys file."
      ask_to_continue
      puts ""
    end

    Gitlab::Shell.new.remove_all_keys

    Gitlab::Shell.new.batch_add_keys do |adder|
      Key.find_each(batch_size: 1000) do |key|
        adder.add_key(key.shell_id, key.key)
        print '.'
      end
    end
    puts ""

    unless $?.success?
      puts "Failed to add keys...".color(:red)
      exit 1
    end

  rescue Gitlab::TaskAbortedByUserError
    puts "Quitting...".color(:red)
    exit 1
  end
end
