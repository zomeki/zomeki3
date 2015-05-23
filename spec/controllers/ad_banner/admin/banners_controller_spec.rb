require 'rails_helper'

RSpec.describe AdBanner::Admin::BannersController, :type => :controller do
  subject { AdBanner::Admin::BannersController }
  it { should < Cms::Controller::Admin::Base }
  it { should include Sys::Controller::Scaffold::Base }

  describe 'GET #index' do
    describe 'routes' do
      subject { {get: "/#{ZomekiCMS::ADMIN_URL_PREFIX}/ad_banner/1/banners"} }
      it { should route_to(controller: 'ad_banner/admin/banners', action: 'index', content: '1') }
    end

    describe 'response' do
      before do
        user = login_as(fg_find_or_create(:sys_user_site_admin).account)
        site = fg_find_or_create(:cms_site_first_example_com)
        script_uri = "#{site.full_uri}#{ZomekiCMS::ADMIN_URL_PREFIX}/ad_banner/1/banners"
        initialize_core(script_uri)
      end

      it 'has banner content' do
        pending 'Failed to login'
        content = fg_find_or_create(:ad_banner_content_banner_1)
        get :index, content: content.id
        assigns(:content).should be_kind_of(AdBanner::Content::Banner)
      end
    end
  end
end
