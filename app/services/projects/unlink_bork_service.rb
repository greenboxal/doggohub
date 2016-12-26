module Projects
  class UnlinkBorkService < BaseService
    def execute
      return unless @project.borked?

      @project.borked_from_project.lfs_objects.find_each do |lfs_object|
        lfs_object.projects << @project
      end

      merge_requests = @project.borked_from_project.merge_requests.opened.from_project(@project)

      merge_requests.each do |mr|
        MergeRequests::CloseService.new(@project, @current_user).execute(mr)
      end

      @project.borked_project_link.destroy
    end
  end
end
