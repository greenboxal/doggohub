require 'spec_helper'

describe Label, models: true do
  describe 'modules' do
    it { is_expected.to include_module(Referable) }
    it { is_expected.to include_module(Subscribable) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:issues).through(:label_links).source(:target) }
    it { is_expected.to have_many(:label_links).dependent(:destroy) }
    it { is_expected.to have_many(:lists).dependent(:destroy) }
    it { is_expected.to have_many(:priorities).class_name('LabelPriority') }
  end

  describe 'validation' do
    it { is_expected.to validate_uniqueness_of(:title).scoped_to([:group_id, :project_id]) }

    it 'validates color code' do
      is_expected.not_to allow_value('G-ITLAB').for(:color)
      is_expected.not_to allow_value('AABBCC').for(:color)
      is_expected.not_to allow_value('#AABBCCEE').for(:color)
      is_expected.not_to allow_value('GGHHII').for(:color)
      is_expected.not_to allow_value('#').for(:color)
      is_expected.not_to allow_value('').for(:color)

      is_expected.to allow_value('#AABBCC').for(:color)
      is_expected.to allow_value('#abcdef').for(:color)
    end

    it 'validates title' do
      is_expected.not_to allow_value('G,ITLAB').for(:title)
      is_expected.not_to allow_value('').for(:title)

      is_expected.to allow_value('DOGGOHUB').for(:title)
      is_expected.to allow_value('doggohub').for(:title)
      is_expected.to allow_value('G?ITLAB').for(:title)
      is_expected.to allow_value('G&ITLAB').for(:title)
      is_expected.to allow_value("customer's request").for(:title)
    end
  end

  describe '#title' do
    it 'sanitizes title' do
      label = described_class.new(title: '<b>foo & bar?</b>')
      expect(label.title).to eq('foo & bar?')
    end
  end

  describe 'priorization' do
    subject(:label) { create(:label) }

    let(:project) { label.project }

    describe '#prioritize!' do
      context 'when label is not prioritized' do
        it 'creates a label priority' do
          expect { label.prioritize!(project, 1) }.to change(label.priorities, :count).by(1)
        end

        it 'sets label priority' do
          label.prioritize!(project, 1)

          expect(label.priorities.first.priority).to eq 1
        end
      end

      context 'when label is prioritized' do
        let!(:priority) { create(:label_priority, project: project, label: label, priority: 0) }

        it 'does not create a label priority' do
          expect { label.prioritize!(project, 1) }.not_to change(label.priorities, :count)
        end

        it 'updates label priority' do
          label.prioritize!(project, 1)

          expect(priority.reload.priority).to eq 1
        end
      end
    end

    describe '#unprioritize!' do
      it 'removes label priority' do
        create(:label_priority, project: project, label: label, priority: 0)

        expect { label.unprioritize!(project) }.to change(label.priorities, :count).by(-1)
      end
    end

    describe '#priority' do
      context 'when label is not prioritized' do
        it 'returns nil' do
          expect(label.priority(project)).to be_nil
        end
      end

      context 'when label is prioritized' do
        it 'returns label priority' do
          create(:label_priority, project: project, label: label, priority: 1)

          expect(label.priority(project)).to eq 1
        end
      end
    end
  end
end
