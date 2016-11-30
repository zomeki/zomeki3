require 'rails_helper'

RSpec.describe AdBanner::Banner, type: :model do
  it 'has a valid factory' do
    banner = build(:ad_banner_banner)
    banner.skip_upload
    expect(banner).to be_valid
  end

  it 'is invalid without a name' do
    banner = build(:ad_banner_banner, name: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:name].size).to eq 1
  end

  it 'is invalid without a title' do
    banner = build(:ad_banner_banner, title: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:title].size).to eq 1
  end

  it 'is invalid without a content' do
    banner = build(:ad_banner_banner, content: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:content_id].size).to eq 1
  end

  it 'is invalid without a state' do
    banner = build(:ad_banner_banner, state: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:state].size).to eq 1
  end

  it 'is invalid without an advertiser name' do
    banner = build(:ad_banner_banner, advertiser_name: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:advertiser_name].size).to eq 1
  end

  it 'is invalid without an url' do
    banner = build(:ad_banner_banner, url: nil)
    banner.skip_upload
    expect(banner).not_to be_valid
    expect(banner.errors[:url].size).to eq 1
  end
end
