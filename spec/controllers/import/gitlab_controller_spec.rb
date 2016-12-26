require 'spec_helper'

describe Import::GitlabController do
  include ImportSpecHelper

  let(:user) { create(:user) }
  let(:token) { "asdasd12345" }
  let(:access_params) { { doggohub_access_token: token } }

  def assign_session_token
    session[:doggohub_access_token] = token
  end

  before do
    sign_in(user)
    allow(controller).to receive(:doggohub_import_enabled?).and_return(true)
  end

  describe "GET callback" do
    it "updates access token" do
      allow_any_instance_of(Gitlab::GitlabImport::Client).
        to receive(:get_token).and_return(token)
      stub_omniauth_provider('doggohub')

      get :callback

      expect(session[:doggohub_access_token]).to eq(token)
      expect(controller).to redirect_to(status_import_doggohub_url)
    end
  end

  describe "GET status" do
    before do
      @repo = OpenStruct.new(path: 'vim', path_with_namespace: 'asd/vim')
      assign_session_token
    end

    it "assigns variables" do
      @project = create(:project, import_type: 'doggohub', creator_id: user.id)
      stub_client(projects: [@repo])

      get :status

      expect(assigns(:already_added_projects)).to eq([@project])
      expect(assigns(:repos)).to eq([@repo])
    end

    it "does not show already added project" do
      @project = create(:project, import_type: 'doggohub', creator_id: user.id, import_source: 'asd/vim')
      stub_client(projects: [@repo])

      get :status

      expect(assigns(:already_added_projects)).to eq([@project])
      expect(assigns(:repos)).to eq([])
    end
  end

  describe "POST create" do
    let(:doggohub_username) { user.username }
    let(:doggohub_user) do
      { username: doggohub_username }.with_indifferent_access
    end
    let(:doggohub_repo) do
      {
        path: 'vim',
        path_with_namespace: "#{doggohub_username}/vim",
        owner: { name: doggohub_username },
        namespace: { path: doggohub_username }
      }.with_indifferent_access
    end

    before do
      stub_client(user: doggohub_user, project: doggohub_repo)
      assign_session_token
    end

    context "when the repository owner is the DoggoHub.com user" do
      context "when the DoggoHub.com user and DoggoHub server user's usernames match" do
        it "takes the current user's namespace" do
          expect(Gitlab::GitlabImport::ProjectCreator).
            to receive(:new).with(doggohub_repo, user.namespace, user, access_params).
            and_return(double(execute: true))

          post :create, format: :js
        end
      end

      context "when the DoggoHub.com user and DoggoHub server user's usernames don't match" do
        let(:doggohub_username) { "someone_else" }

        it "takes the current user's namespace" do
          expect(Gitlab::GitlabImport::ProjectCreator).
            to receive(:new).with(doggohub_repo, user.namespace, user, access_params).
            and_return(double(execute: true))

          post :create, format: :js
        end
      end
    end

    context "when the repository owner is not the DoggoHub.com user" do
      let(:other_username) { "someone_else" }

      before do
        doggohub_repo["namespace"]["path"] = other_username
        assign_session_token
      end

      context "when a namespace with the DoggoHub.com user's username already exists" do
        let!(:existing_namespace) { create(:namespace, name: other_username, owner: user) }

        context "when the namespace is owned by the DoggoHub server user" do
          it "takes the existing namespace" do
            expect(Gitlab::GitlabImport::ProjectCreator).
              to receive(:new).with(doggohub_repo, existing_namespace, user, access_params).
              and_return(double(execute: true))

            post :create, format: :js
          end
        end

        context "when the namespace is not owned by the DoggoHub server user" do
          before do
            existing_namespace.owner = create(:user)
            existing_namespace.save
          end

          it "doesn't create a project" do
            expect(Gitlab::GitlabImport::ProjectCreator).
              not_to receive(:new)

            post :create, format: :js
          end
        end
      end

      context "when a namespace with the DoggoHub.com user's username doesn't exist" do
        context "when current user can create namespaces" do
          it "creates the namespace" do
            expect(Gitlab::GitlabImport::ProjectCreator).
              to receive(:new).and_return(double(execute: true))

            expect { post :create, format: :js }.to change(Namespace, :count).by(1)
          end

          it "takes the new namespace" do
            expect(Gitlab::GitlabImport::ProjectCreator).
              to receive(:new).with(doggohub_repo, an_instance_of(Group), user, access_params).
              and_return(double(execute: true))

            post :create, format: :js
          end
        end

        context "when current user can't create namespaces" do
          before do
            user.update_attribute(:can_create_group, false)
          end

          it "doesn't create the namespace" do
            expect(Gitlab::GitlabImport::ProjectCreator).
              to receive(:new).and_return(double(execute: true))

            expect { post :create, format: :js }.not_to change(Namespace, :count)
          end

          it "takes the current user's namespace" do
            expect(Gitlab::GitlabImport::ProjectCreator).
              to receive(:new).with(doggohub_repo, user.namespace, user, access_params).
              and_return(double(execute: true))

            post :create, format: :js
          end
        end
      end
    end
  end
end
