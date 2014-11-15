require 'spec_helper'

describe AdBanner::Banner do
  before do
    login_as(fg_find_or_create(:sys_user_site_admin).account)
    site = fg_find_or_create(:cms_site_first_example_com)
    script_uri = "#{site.full_uri}#{CmsCMS::ADMIN_URL_PREFIX}/ad_banner/1/banners"
    initialize_core(script_uri)
  end

  it 'has a valid factory' do
    pending 'Failed to login'
    group = FactoryGirl.build(:ad_banner_group_1)
    expect(group).to be_valid
  end

  it 'is invalid without a name' do
    pending 'Failed to login'
    group = FactoryGirl.build(:ad_banner_group_1, name: nil)
    expect(group).not_to be_valid
    expect(group.errors[:name].size).to eq(1)
  end

  it 'is invalid without a title' do
    pending 'Failed to login'
    group = FactoryGirl.build(:ad_banner_group_1, title: nil)
    expect(group).not_to be_valid
    expect(group.errors[:title].size).to eq(1)
  end

  context 'after initialize' do
    it 'sets 10 as sort_no' do
      pending 'Failed to login'
      group = fg_find_or_create :ad_banner_group_1
      expect(group.sort_no).to eq 10
    end
  end
end
