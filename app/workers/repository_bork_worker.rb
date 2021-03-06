class RepositoryBorkWorker
  include Sidekiq::Worker
  include Gitlab::ShellAdapter
  include DedicatedSidekiqQueue

  def perform(project_id, borked_from_repository_storage_path, source_path, target_path)
    Gitlab::Metrics.add_event(:bork_repository,
                              source_path: source_path,
                              target_path: target_path)

    project = Project.find_by_id(project_id)

    unless project.present?
      logger.error("Project #{project_id} no longer exists!")
      return
    end

    result = doggohub_shell.bork_repository(borked_from_repository_storage_path, source_path,
                                          project.repository_storage_path, target_path)
    unless result
      logger.error("Unable to bork project #{project_id} for repository #{source_path} -> #{target_path}")
      project.mark_import_as_failed('The project could not be borked.')
      return
    end

    project.repository.after_import

    unless project.valid_repo?
      logger.error("Project #{project_id} had an invalid repository after bork")
      project.mark_import_as_failed('The borked repository is invalid.')
      return
    end

    project.import_finish
  end
end
