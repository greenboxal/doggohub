require 'spec_helper'

describe Projects::BorkService, services: true do
  describe :bork_by_user do
    before do
      @from_namespace = create(:namespace)
      @from_user = create(:user, namespace: @from_namespace )
      @from_project = create(:project,
                             creator_id: @from_user.id,
                             namespace: @from_namespace,
                             star_count: 107,
                             description: 'wow such project')
      @to_namespace = create(:namespace)
      @to_user = create(:user, namespace: @to_namespace)
      @from_project.add_user(@to_user, :developer)
    end

    context 'bork project' do
      context 'when borker is a guest' do
        before do
          @guest = create(:user)
          @from_project.add_user(@guest, :guest)
        end
        subject { bork_project(@from_project, @guest) }

        it { is_expected.not_to be_persisted }
        it { expect(subject.errors[:borked_from_project_id]).to eq(['is forbidden']) }
      end

      describe "successfully creates project in the user namespace" do
        let(:to_project) { bork_project(@from_project, @to_user) }

        it { expect(to_project).to be_persisted }
        it { expect(to_project.errors).to be_empty }
        it { expect(to_project.owner).to eq(@to_user) }
        it { expect(to_project.namespace).to eq(@to_user.namespace) }
        it { expect(to_project.star_count).to be_zero }
        it { expect(to_project.description).to eq(@from_project.description) }
      end
    end

    context 'project already exists' do
      it "fails due to validation, not transaction failure" do
        @existing_project = create(:project, creator_id: @to_user.id, name: @from_project.name, namespace: @to_namespace)
        @to_project = bork_project(@from_project, @to_user)
        expect(@existing_project).to be_persisted

        expect(@to_project).not_to be_persisted
        expect(@to_project.errors[:name]).to eq(['has already been taken'])
        expect(@to_project.errors[:path]).to eq(['has already been taken'])
      end
    end

    context 'DoggoHub CI is enabled' do
      it "borks and enables CI for bork" do
        @from_project.enable_ci
        @to_project = bork_project(@from_project, @to_user)
        expect(@to_project.builds_enabled?).to be_truthy
      end
    end

    context "when project has restricted visibility level" do
      context "and only one visibility level is restricted" do
        before do
          @from_project.update_attributes(visibility_level: Gitlab::VisibilityLevel::INTERNAL)
          stub_application_setting(restricted_visibility_levels: [Gitlab::VisibilityLevel::INTERNAL])
        end

        it "creates bork with highest allowed level" do
          borked_project = bork_project(@from_project, @to_user)

          expect(borked_project.visibility_level).to eq(Gitlab::VisibilityLevel::PUBLIC)
        end
      end

      context "and all visibility levels are restricted" do
        before do
          stub_application_setting(restricted_visibility_levels: [Gitlab::VisibilityLevel::PUBLIC, Gitlab::VisibilityLevel::INTERNAL, Gitlab::VisibilityLevel::PRIVATE])
        end

        it "creates bork with private visibility levels" do
          borked_project = bork_project(@from_project, @to_user)

          expect(borked_project.visibility_level).to eq(Gitlab::VisibilityLevel::PRIVATE)
        end
      end
    end
  end

  describe :bork_to_namespace do
    before do
      @group_owner = create(:user)
      @developer   = create(:user)
      @project     = create(:project, creator_id: @group_owner.id,
                                      star_count: 777,
                                      description: 'Wow, such a cool project!')
      @group = create(:group)
      @group.add_user(@group_owner, GroupMember::OWNER)
      @group.add_user(@developer,   GroupMember::DEVELOPER)
      @project.add_user(@developer,   :developer)
      @project.add_user(@group_owner, :developer)
      @opts = { namespace: @group }
    end

    context 'bork project for group' do
      it 'group owner successfully borks project into the group' do
        to_project = bork_project(@project, @group_owner, @opts)

        expect(to_project).to             be_persisted
        expect(to_project.errors).to      be_empty
        expect(to_project.owner).to       eq(@group)
        expect(to_project.namespace).to   eq(@group)
        expect(to_project.name).to        eq(@project.name)
        expect(to_project.path).to        eq(@project.path)
        expect(to_project.description).to eq(@project.description)
        expect(to_project.star_count).to  be_zero
      end
    end

    context 'bork project for group when user not owner' do
      it 'group developer fails to bork project into the group' do
        to_project = bork_project(@project, @developer, @opts)
        expect(to_project.errors[:namespace]).to eq(['is not valid'])
      end
    end

    context 'project already exists in group' do
      it 'fails due to validation, not transaction failure' do
        existing_project = create(:project, name: @project.name,
                                            namespace: @group)
        to_project = bork_project(@project, @group_owner, @opts)
        expect(existing_project.persisted?).to be_truthy
        expect(to_project.errors[:name]).to eq(['has already been taken'])
        expect(to_project.errors[:path]).to eq(['has already been taken'])
      end
    end
  end

  def bork_project(from_project, user, params = {})
    allow(RepositoryBorkWorker).to receive(:perform_async).and_return(true)
    Projects::BorkService.new(from_project, user, params).execute
  end
end
