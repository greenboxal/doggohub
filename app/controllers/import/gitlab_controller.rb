class Import::GitlabController < Import::BaseController
  before_action :verify_doggohub_import_enabled
  before_action :doggohub_auth, except: :callback

  rescue_from OAuth2::Error, with: :doggohub_unauthorized

  def callback
    session[:doggohub_access_token] = client.get_token(params[:code], callback_import_doggohub_url)
    redirect_to status_import_doggohub_url
  end

  def status
    @repos = client.projects

    @already_added_projects = current_user.created_projects.where(import_type: "doggohub")
    already_added_projects_names = @already_added_projects.pluck(:import_source)

    @repos = @repos.to_a.reject{ |repo| already_added_projects_names.include? repo["path_with_namespace"] }
  end

  def jobs
    jobs = current_user.created_projects.where(import_type: "doggohub").to_json(only: [:id, :import_status])
    render json: jobs
  end

  def create
    @repo_id = params[:repo_id].to_i
    repo = client.project(@repo_id)
    @project_name = repo['name']
    @target_namespace = find_or_create_namespace(repo['namespace']['path'], client.user['username'])

    if current_user.can?(:create_projects, @target_namespace)
      @project = Gitlab::GitlabImport::ProjectCreator.new(repo, @target_namespace, current_user, access_params).execute
    else
      render 'unauthorized'
    end
  end

  private

  def client
    @client ||= Gitlab::GitlabImport::Client.new(session[:doggohub_access_token])
  end

  def verify_doggohub_import_enabled
    render_404 unless doggohub_import_enabled?
  end

  def doggohub_auth
    if session[:doggohub_access_token].blank?
      go_to_doggohub_for_permissions
    end
  end

  def go_to_doggohub_for_permissions
    redirect_to client.authorize_url(callback_import_doggohub_url)
  end

  def doggohub_unauthorized
    go_to_doggohub_for_permissions
  end

  def access_params
    { doggohub_access_token: session[:doggohub_access_token] }
  end
end
