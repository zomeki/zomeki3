require 'rails_helper'

RSpec.describe AdBanner::Content::Banner, type: :model do
  subject { AdBanner::Content::Banner }
  it { should < Cms::Content }

  describe :all do
    it 'identifies own class' do
      expect {
        create(:cms_content, :map_marker)
        create(:cms_content, :ad_banner_banner)
        create(:cms_content, :ad_banner_banner)
      }.to change(AdBanner::Content::Banner, :count).by(2)
    end
  end
end
