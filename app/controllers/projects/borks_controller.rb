class Projects::BorksController < Projects::ApplicationController
  include ContinueParams

  # Authorize
  before_action :require_non_empty_project
  before_action :authorize_download_code!
  before_action :authenticate_user!, only: [:new, :create]

  def index
    base_query = project.borks.includes(:creator)

    @borks               = base_query.merge(ProjectsFinder.new.execute(current_user))
    @total_borks_count   = base_query.size
    @private_borks_count = @total_borks_count - @borks.size
    @public_borks_count  = @total_borks_count - @private_borks_count

    @sort  = params[:sort] || 'id_desc'
    @borks = @borks.search(params[:filter_projects]) if params[:filter_projects].present?
    @borks = @borks.order_by(@sort).page(params[:page])

    respond_to do |format|
      format.html

      format.json do
        render json: {
          html: view_to_html_string("projects/borks/_projects", projects: @borks)
        }
      end
    end
  end

  def new
    @namespaces = current_user.manageable_namespaces
    @namespaces.delete(@project.namespace)
  end

  def create
    namespace = Namespace.find(params[:namespace_key])

    @borked_project = namespace.projects.find_by(path: project.path)
    @borked_project = nil unless @borked_project && @borked_project.borked_from_project == project

    @borked_project ||= ::Projects::BorkService.new(project, current_user, namespace: namespace).execute

    if @borked_project.saved? && @borked_project.borked?
      if @borked_project.import_in_progress?
        redirect_to namespace_project_import_path(@borked_project.namespace, @borked_project, continue: continue_params)
      else
        if continue_params
          redirect_to continue_params[:to], notice: continue_params[:notice]
        else
          redirect_to namespace_project_path(@borked_project.namespace, @borked_project), notice: "The project '#{@borked_project.name}' was successfully borked."
        end
      end
    else
      render :error
    end
  end
end
