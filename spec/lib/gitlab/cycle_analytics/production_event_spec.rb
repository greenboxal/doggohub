require 'spec_helper'
require 'lib/doggohub/cycle_analytics/shared_event_spec'

describe Gitlab::CycleAnalytics::ProductionEvent do
  it_behaves_like 'default query config' do
    it 'has the default order' do
      expect(event.order).to eq(event.start_time_attrs)
    end
  end
end
