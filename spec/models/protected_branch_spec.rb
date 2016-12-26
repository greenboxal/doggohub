require 'spec_helper'

describe ProtectedBranch, models: true do
  subject { build_stubbed(:protected_branch) }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe "Mass assignment" do
  end

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "#matches?" do
    context "when the protected branch setting is not a wildcard" do
      let(:protected_branch) { build(:protected_branch, name: "production/some-branch") }

      it "returns true for branch names that are an exact match" do
        expect(protected_branch.matches?("production/some-branch")).to be true
      end

      it "returns false for branch names that are not an exact match" do
        expect(protected_branch.matches?("staging/some-branch")).to be false
      end
    end

    context "when the protected branch name contains wildcard(s)" do
      context "when there is a single '*'" do
        let(:protected_branch) { build(:protected_branch, name: "production/*") }

        it "returns true for branch names matching the wildcard" do
          expect(protected_branch.matches?("production/some-branch")).to be true
          expect(protected_branch.matches?("production/")).to be true
        end

        it "returns false for branch names not matching the wildcard" do
          expect(protected_branch.matches?("staging/some-branch")).to be false
          expect(protected_branch.matches?("production")).to be false
        end
      end

      context "when the wildcard contains regex symbols other than a '*'" do
        let(:protected_branch) { build(:protected_branch, name: "pro.duc.tion/*") }

        it "returns true for branch names matching the wildcard" do
          expect(protected_branch.matches?("pro.duc.tion/some-branch")).to be true
        end

        it "returns false for branch names not matching the wildcard" do
          expect(protected_branch.matches?("production/some-branch")).to be false
          expect(protected_branch.matches?("proXducYtion/some-branch")).to be false
        end
      end

      context "when there are '*'s at either end" do
        let(:protected_branch) { build(:protected_branch, name: "*/production/*") }

        it "returns true for branch names matching the wildcard" do
          expect(protected_branch.matches?("doggohub/production/some-branch")).to be true
          expect(protected_branch.matches?("/production/some-branch")).to be true
          expect(protected_branch.matches?("doggohub/production/")).to be true
          expect(protected_branch.matches?("/production/")).to be true
        end

        it "returns false for branch names not matching the wildcard" do
          expect(protected_branch.matches?("doggohubproductionsome-branch")).to be false
          expect(protected_branch.matches?("production/some-branch")).to be false
          expect(protected_branch.matches?("doggohub/production")).to be false
          expect(protected_branch.matches?("production")).to be false
        end
      end

      context "when there are arbitrarily placed '*'s" do
        let(:protected_branch) { build(:protected_branch, name: "pro*duction/*/doggohub/*") }

        it "returns true for branch names matching the wildcard" do
          expect(protected_branch.matches?("production/some-branch/doggohub/second-branch")).to be true
          expect(protected_branch.matches?("proXYZduction/some-branch/doggohub/second-branch")).to be true
          expect(protected_branch.matches?("proXYZduction/doggohub/doggohub/doggohub")).to be true
          expect(protected_branch.matches?("proXYZduction//doggohub/")).to be true
          expect(protected_branch.matches?("proXYZduction/some-branch/doggohub/")).to be true
          expect(protected_branch.matches?("proXYZduction//doggohub/some-branch")).to be true
        end

        it "returns false for branch names not matching the wildcard" do
          expect(protected_branch.matches?("production/some-branch/not-doggohub/second-branch")).to be false
          expect(protected_branch.matches?("prodXYZuction/some-branch/doggohub/second-branch")).to be false
          expect(protected_branch.matches?("proXYZduction/doggohub/some-branch/doggohub")).to be false
          expect(protected_branch.matches?("proXYZduction/doggohub//")).to be false
          expect(protected_branch.matches?("proXYZduction/doggohub/")).to be false
          expect(protected_branch.matches?("proXYZduction//some-branch/doggohub")).to be false
        end
      end
    end
  end

  describe "#matching" do
    context "for direct matches" do
      it "returns a list of protected branches matching the given branch name" do
        production = create(:protected_branch, name: "production")
        staging = create(:protected_branch, name: "staging")

        expect(ProtectedBranch.matching("production")).to include(production)
        expect(ProtectedBranch.matching("production")).not_to include(staging)
      end

      it "accepts a list of protected branches to search from, so as to avoid a DB call" do
        production = build(:protected_branch, name: "production")
        staging = build(:protected_branch, name: "staging")

        expect(ProtectedBranch.matching("production")).to be_empty
        expect(ProtectedBranch.matching("production", protected_branches: [production, staging])).to include(production)
        expect(ProtectedBranch.matching("production", protected_branches: [production, staging])).not_to include(staging)
      end
    end

    context "for wildcard matches" do
      it "returns a list of protected branches matching the given branch name" do
        production = create(:protected_branch, name: "production/*")
        staging = create(:protected_branch, name: "staging/*")

        expect(ProtectedBranch.matching("production/some-branch")).to include(production)
        expect(ProtectedBranch.matching("production/some-branch")).not_to include(staging)
      end

      it "accepts a list of protected branches to search from, so as to avoid a DB call" do
        production = build(:protected_branch, name: "production/*")
        staging = build(:protected_branch, name: "staging/*")

        expect(ProtectedBranch.matching("production/some-branch")).to be_empty
        expect(ProtectedBranch.matching("production/some-branch", protected_branches: [production, staging])).to include(production)
        expect(ProtectedBranch.matching("production/some-branch", protected_branches: [production, staging])).not_to include(staging)
      end
    end
  end
end
