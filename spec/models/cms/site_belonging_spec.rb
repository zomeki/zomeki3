require 'rails_helper'

RSpec.describe Cms::SiteBelonging, type: :model do
  it 'is valid with site_id and group_id' do
    belonging = build(:cms_site_belonging)
    expect(belonging).to be_valid
  end

  it 'is invalid without site_id' do
    belonging = build(:cms_site_belonging, site_id: nil, group_id: 1)
    belonging.validate
    expect(belonging.errors[:site_id].size).to eq 1
  end
end
