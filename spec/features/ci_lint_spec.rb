require 'spec_helper'

describe 'CI Lint' do
  before do
    login_as :user
  end

  describe 'YAML parsing' do
    before do
      visit ci_lint_path
      fill_in 'content', with: yaml_content
      click_on 'Validate'
    end

    context 'YAML is correct' do
      let(:yaml_content) do
        File.read(Rails.root.join('spec/support/doggohub_stubs/doggohub_ci.yml'))
      end

      it 'parses Yaml' do
        within "table" do
          expect(page).to have_content('Job - rspec')
          expect(page).to have_content('Job - spinach')
          expect(page).to have_content('Deploy Job - staging')
          expect(page).to have_content('Deploy Job - production')
        end
      end
    end

    context 'YAML is incorrect' do
      let(:yaml_content) { '' }

      it 'displays information about an error' do
        expect(page).to have_content('Status: syntax is incorrect')
        expect(page).to have_content('Error: Please provide content of .doggohub-ci.yml')
      end
    end

    describe 'YAML revalidate' do
      let(:yaml_content) { 'my yaml content' }

      it 'loads previous YAML content after validation' do
        expect(page).to have_field('content', with: 'my yaml content', type: 'textarea')
      end
    end
  end
end
