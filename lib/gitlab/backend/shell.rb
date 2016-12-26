require 'securerandom'

module Gitlab
  class Shell
    class Error < StandardError; end

    KeyAdder = Struct.new(:io) do
      def add_key(id, key)
        key = Gitlab::Shell.strip_key(key)
        # Newline and tab are part of the 'protocol' used to transmit id+key to the other end
        if key.include?("\t") || key.include?("\n")
          raise Error.new("Invalid key: #{key.inspect}")
        end

        io.puts("#{id}\t#{key}")
      end
    end

    class << self
      def secret_token
        @secret_token ||= begin
          File.read(Gitlab.config.doggohub_shell.secret_file).chomp
        end
      end

      def ensure_secret_token!
        return if File.exist?(File.join(Gitlab.config.doggohub_shell.path, '.doggohub_shell_secret'))

        generate_and_link_secret_token
      end

      def version_required
        @version_required ||= File.read(Rails.root.
                                        join('DOGGOHUB_SHELL_VERSION')).strip
      end

      def strip_key(key)
        key.split(/ /)[0, 2].join(' ')
      end

      private

      # Create (if necessary) and link the secret token file
      def generate_and_link_secret_token
        secret_file = Gitlab.config.doggohub_shell.secret_file
        shell_path = Gitlab.config.doggohub_shell.path

        unless File.size?(secret_file)
          # Generate a new token of 16 random hexadecimal characters and store it in secret_file.
          @secret_token = SecureRandom.hex(16)
          File.write(secret_file, @secret_token)
        end

        link_path = File.join(shell_path, '.doggohub_shell_secret')
        if File.exist?(shell_path) && !File.exist?(link_path)
          FileUtils.symlink(secret_file, link_path)
        end
      end
    end

    # Init new repository
    #
    # storage - project's storage path
    # name - project path with namespace
    #
    # Ex.
    #   add_repository("/path/to/storage", "doggohub/doggohub-ci")
    #
    def add_repository(storage, name)
      Gitlab::Utils.system_silent([doggohub_shell_projects_path,
                                   'add-project', storage, "#{name}.git"])
    end

    # Import repository
    #
    # storage - project's storage path
    # name - project path with namespace
    #
    # Ex.
    #   import_repository("/path/to/storage", "doggohub/doggohub-ci", "https://github.com/randx/six.git")
    #
    def import_repository(storage, name, url)
      output, status = Popen::popen([doggohub_shell_projects_path, 'import-project',
                                     storage, "#{name}.git", url, '900'])
      raise Error, output unless status.zero?
      true
    end

    # Move repository
    # storage - project's storage path
    # path - project path with namespace
    # new_path - new project path with namespace
    #
    # Ex.
    #   mv_repository("/path/to/storage", "doggohub/doggohub-ci", "randx/doggohub-ci-new")
    #
    def mv_repository(storage, path, new_path)
      Gitlab::Utils.system_silent([doggohub_shell_projects_path, 'mv-project',
                                   storage, "#{path}.git", "#{new_path}.git"])
    end

    # Bork repository to new namespace
    # borked_from_storage - borked-from project's storage path
    # path - project path with namespace
    # borked_to_storage - borked-to project's storage path
    # bork_namespace - namespace for borked project
    #
    # Ex.
    #  bork_repository("/path/to/borked_from/storage", "doggohub/doggohub-ci", "/path/to/borked_to/storage", "randx")
    #
    def bork_repository(borked_from_storage, path, borked_to_storage, bork_namespace)
      Gitlab::Utils.system_silent([doggohub_shell_projects_path, 'bork-project',
                                   borked_from_storage, "#{path}.git", borked_to_storage,
                                   bork_namespace])
    end

    # Remove repository from file system
    #
    # storage - project's storage path
    # name - project path with namespace
    #
    # Ex.
    #   remove_repository("/path/to/storage", "doggohub/doggohub-ci")
    #
    def remove_repository(storage, name)
      Gitlab::Utils.system_silent([doggohub_shell_projects_path,
                                   'rm-project', storage, "#{name}.git"])
    end

    # Add new key to doggohub-shell
    #
    # Ex.
    #   add_key("key-42", "sha-rsa ...")
    #
    def add_key(key_id, key_content)
      Gitlab::Utils.system_silent([doggohub_shell_keys_path,
                                   'add-key', key_id, self.class.strip_key(key_content)])
    end

    # Batch-add keys to authorized_keys
    #
    # Ex.
    #   batch_add_keys { |adder| adder.add_key("key-42", "sha-rsa ...") }
    def batch_add_keys(&block)
      IO.popen(%W(#{doggohub_shell_path}/bin/doggohub-keys batch-add-keys), 'w') do |io|
        block.call(KeyAdder.new(io))
      end
    end

    # Remove ssh key from doggohub shell
    #
    # Ex.
    #   remove_key("key-342", "sha-rsa ...")
    #
    def remove_key(key_id, key_content)
      Gitlab::Utils.system_silent([doggohub_shell_keys_path,
                                   'rm-key', key_id, key_content])
    end

    # Remove all ssh keys from doggohub shell
    #
    # Ex.
    #   remove_all_keys
    #
    def remove_all_keys
      Gitlab::Utils.system_silent([doggohub_shell_keys_path, 'clear'])
    end

    # Add empty directory for storing repositories
    #
    # Ex.
    #   add_namespace("/path/to/storage", "doggohub")
    #
    def add_namespace(storage, name)
      FileUtils.mkdir(full_path(storage, name), mode: 0770) unless exists?(storage, name)
    end

    # Remove directory from repositories storage
    # Every repository inside this directory will be removed too
    #
    # Ex.
    #   rm_namespace("/path/to/storage", "doggohub")
    #
    def rm_namespace(storage, name)
      FileUtils.rm_r(full_path(storage, name), force: true)
    end

    # Move namespace directory inside repositories storage
    #
    # Ex.
    #   mv_namespace("/path/to/storage", "doggohub", "doggohubhq")
    #
    def mv_namespace(storage, old_name, new_name)
      return false if exists?(storage, new_name) || !exists?(storage, old_name)

      FileUtils.mv(full_path(storage, old_name), full_path(storage, new_name))
    end

    def url_to_repo(path)
      Gitlab.config.doggohub_shell.ssh_path_prefix + "#{path}.git"
    end

    # Return DoggoHub shell version
    def version
      doggohub_shell_version_file = "#{doggohub_shell_path}/VERSION"

      if File.readable?(doggohub_shell_version_file)
        File.read(doggohub_shell_version_file).chomp
      end
    end

    # Check if such directory exists in repositories.
    #
    # Usage:
    #   exists?(storage, 'doggohub')
    #   exists?(storage, 'doggohub/cookies.git')
    #
    def exists?(storage, dir_name)
      File.exist?(full_path(storage, dir_name))
    end

    protected

    def doggohub_shell_path
      Gitlab.config.doggohub_shell.path
    end

    def doggohub_shell_user_home
      File.expand_path("~#{Gitlab.config.doggohub_shell.ssh_user}")
    end

    def full_path(storage, dir_name)
      raise ArgumentError.new("Directory name can't be blank") if dir_name.blank?

      File.join(storage, dir_name)
    end

    def doggohub_shell_projects_path
      File.join(doggohub_shell_path, 'bin', 'doggohub-projects')
    end

    def doggohub_shell_keys_path
      File.join(doggohub_shell_path, 'bin', 'doggohub-keys')
    end
  end
end
