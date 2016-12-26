require 'tasks/doggohub/task_helpers'

# Prevent StateMachine warnings from outputting during a cron task
StateMachines::Machine.ignore_method_conflicts = true if ENV['CRON']

namespace :doggohub do
  include Gitlab::TaskHelpers
end
