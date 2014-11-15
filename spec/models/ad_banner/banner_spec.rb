require 'spec_helper'

describe AdBanner::Banner do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    banner = FactoryGirl.build(:ad_banner_banner_1)
    banner.skip_upload
    expect(banner).to be_valid
  end

  it 'is invalid without a name' do
    banner = FactoryGirl.build(:ad_banner_banner_1, name: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:name].size).to eq(1)
  end

  it 'is invalid without a title' do
    banner = FactoryGirl.build(:ad_banner_banner_1, title: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:title].size).to eq(1)
  end

  it 'is invalid without a content' do
    banner = FactoryGirl.build(:ad_banner_banner_1, content: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:content_id].size).to eq(1)
  end

  it 'is invalid without a state' do
    banner = FactoryGirl.build(:ad_banner_banner_1, state: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:state].size).to eq(1)
  end

  it 'is invalid without an advertiser name' do
    banner = FactoryGirl.build(:ad_banner_banner_1, advertiser_name: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:advertiser_name].size).to eq(1)
  end

  it 'is invalid without an url' do
    banner = FactoryGirl.build(:ad_banner_banner_1, url: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:url].size).to eq(1)
  end
end
