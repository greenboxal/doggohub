require 'spec_helper'

describe Projects::UpdateService, services: true do
  describe :update_by_user do
    before do
      @user = create :user
      @admin = create :user, admin: true
      @project = create :project, creator_id: @user.id, namespace: @user.namespace
      @opts = {}
    end

    context 'is private when updated to private' do
      before do
        @created_private = @project.private?

        @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
        update_project(@project, @user, @opts)
      end

      it { expect(@created_private).to be_truthy }
      it { expect(@project.private?).to be_truthy }
    end

    context 'is internal when updated to internal' do
      before do
        @created_private = @project.private?

        @opts.merge!(visibility_level: Gitlab::VisibilityLevel::INTERNAL)
        update_project(@project, @user, @opts)
      end

      it { expect(@created_private).to be_truthy }
      it { expect(@project.internal?).to be_truthy }
    end

    context 'is public when updated to public' do
      before do
        @created_private = @project.private?

        @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
        update_project(@project, @user, @opts)
      end

      it { expect(@created_private).to be_truthy }
      it { expect(@project.public?).to be_truthy }
    end

    context 'respect configured visibility restrictions setting' do
      before(:each) do
        stub_application_setting(restricted_visibility_levels: [Gitlab::VisibilityLevel::PUBLIC])
      end

      context 'is private when updated to private' do
        before do
          @created_private = @project.private?

          @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
          update_project(@project, @user, @opts)
        end

        it { expect(@created_private).to be_truthy }
        it { expect(@project.private?).to be_truthy }
      end

      context 'is internal when updated to internal' do
        before do
          @created_private = @project.private?

          @opts.merge!(visibility_level: Gitlab::VisibilityLevel::INTERNAL)
          update_project(@project, @user, @opts)
        end

        it { expect(@created_private).to be_truthy }
        it { expect(@project.internal?).to be_truthy }
      end

      context 'is private when updated to public' do
        before do
          @created_private = @project.private?

          @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
          update_project(@project, @user, @opts)
        end

        it { expect(@created_private).to be_truthy }
        it { expect(@project.private?).to be_truthy }
      end

      context 'is public when updated to public by admin' do
        before do
          @created_private = @project.private?

          @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
          update_project(@project, @admin, @opts)
        end

        it { expect(@created_private).to be_truthy }
        it { expect(@project.public?).to be_truthy }
      end
    end
  end

  describe :visibility_level do
    let(:user) { create :user, admin: true }
    let(:project) { create(:project, :internal) }
    let(:borked_project) { create(:borked_project_with_submodules, :internal) }
    let(:opts) { {} }

    before do
      borked_project.build_borked_project_link(borked_to_project_id: borked_project.id, borked_from_project_id: project.id)
      borked_project.save

      @created_internal = project.internal?
      @bork_created_internal = borked_project.internal?
    end

    context 'updates borks visibility level when parent set to more restrictive' do
      before do
        opts.merge!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
        update_project(project, user, opts).inspect
      end

      it { expect(@created_internal).to be_truthy }
      it { expect(@bork_created_internal).to be_truthy }
      it { expect(project.private?).to be_truthy }
      it { expect(project.borks.first.private?).to be_truthy }
    end

    context 'does not update borks visibility level when parent set to less restrictive' do
      before do
        opts.merge!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
        update_project(project, user, opts).inspect
      end

      it { expect(@created_internal).to be_truthy }
      it { expect(@bork_created_internal).to be_truthy }
      it { expect(project.public?).to be_truthy }
      it { expect(project.borks.first.internal?).to be_truthy }
    end
  end

  def update_project(project, user, opts)
    Projects::UpdateService.new(project, user, opts).execute
  end
end
