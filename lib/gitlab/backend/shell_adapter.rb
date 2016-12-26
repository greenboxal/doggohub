# == DoggoHub Shell mixin
#
# Provide a shortcut to Gitlab::Shell instance by doggohub_shell
#
module Gitlab
  module ShellAdapter
    def doggohub_shell
      Gitlab::Shell.new
    end
  end
end
