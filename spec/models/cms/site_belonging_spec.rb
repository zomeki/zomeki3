require 'spec_helper'

describe Cms::SiteBelonging do
  it 'is valid with site_id and group_id' do
    expect(FactoryGirl.build(:cms_site_belonging, site_id: 1, group_id: 1)).to be_valid
  end

  it 'is invalid without site_id' do
    belonging = FactoryGirl.build(:cms_site_belonging, site_id: nil, group_id: 1)
    expect(belonging).not_to be_valid
    expect(belonging.errors[:site_id].size).to eq(1)
  end

  it 'is invalid without group_id' do
    belonging = FactoryGirl.build(:cms_site_belonging, site_id: 1, group_id: nil)
    expect(belonging).not_to be_valid
    expect(belonging.errors[:group_id].size).to eq(1)
  end
end
