require 'rails_helper'

RSpec.describe AdBanner::Group, type: :model do
  it 'has a valid factory' do
    group = build(:ad_banner_group)
    expect(group).to be_valid
  end

  it 'is invalid without a name' do
    group = build(:ad_banner_group, name: nil)
    group.validate
    expect(group.errors[:name].size).to eq 1
  end

  it 'is invalid without a title' do
    group = build(:ad_banner_group, title: nil)
    group.validate
    expect(group.errors[:title].size).to eq 1
  end

  context 'after initialize' do
    it 'sets 10 as sort_no' do
      group = create(:ad_banner_group, sort_no: nil)
      group.reload
      expect(group.sort_no).to eq 10
    end
  end
end
