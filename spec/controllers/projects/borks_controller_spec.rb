require 'spec_helper'

describe Projects::BorksController do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public) }
  let(:borked_project) { Projects::BorkService.new(project, user).execute }
  let(:group) { create(:group, owner: borked_project.creator) }

  describe 'GET index' do
    def get_borks
      get :index,
        namespace_id: project.namespace.to_param,
        project_id: project.to_param
    end

    context 'when bork is public' do
      before { borked_project.update_attribute(:visibility_level, Project::PUBLIC) }

      it 'is visible for non logged in users' do
        get_borks

        expect(assigns[:borks]).to be_present
      end
    end

    context 'when bork is private' do
      before do
        borked_project.update_attributes(visibility_level: Project::PRIVATE, group: group)
      end

      it 'is not be visible for non logged in users' do
        get_borks

        expect(assigns[:borks]).to be_blank
      end

      context 'when user is logged in' do
        before { sign_in(project.creator) }

        context 'when user is not a Project member neither a group member' do
          it 'does not see the Project listed' do
            get_borks

            expect(assigns[:borks]).to be_blank
          end
        end

        context 'when user is a member of the Project' do
          before { borked_project.team << [project.creator, :developer] }

          it 'sees the project listed' do
            get_borks

            expect(assigns[:borks]).to be_present
          end
        end

        context 'when user is a member of the Group' do
          before { borked_project.group.add_developer(project.creator) }

          it 'sees the project listed' do
            get_borks

            expect(assigns[:borks]).to be_present
          end
        end
      end
    end
  end

  describe 'GET new' do
    def get_new
      get :new,
        namespace_id: project.namespace.to_param,
        project_id: project.to_param
    end

    context 'when user is signed in' do
      it 'responds with status 200' do
        sign_in(user)

        get_new

        expect(response).to have_http_status(200)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign-in page' do
        sign_out(user)

        get_new

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST create' do
    def post_create
      post :create,
        namespace_id: project.namespace.to_param,
        project_id: project.to_param,
        namespace_key: user.namespace.id
    end

    context 'when user is signed in' do
      it 'responds with status 302' do
        sign_in(user)

        post_create

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(namespace_project_import_path(user.namespace, project))
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign-in page' do
        sign_out(user)

        post_create

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
