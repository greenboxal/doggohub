require 'rails_helper'

describe Gitlab, lib: true do
  describe '.com?' do
    it 'is true when on DoggoHub.com' do
      stub_config_setting(url: 'https://doggohub.com')

      expect(described_class.com?).to eq true
    end

    it 'is true when on staging' do
      stub_config_setting(url: 'https://staging.doggohub.com')

      expect(described_class.com?).to eq true
    end

    it 'is false when not on DoggoHub.com' do
      stub_config_setting(url: 'http://example.com')

      expect(described_class.com?).to eq false
    end
  end
end
