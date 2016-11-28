require 'rails_helper'

RSpec.describe AdBanner::Admin::BannersController, type: :controller do
  shared_examples_for 'routes correct' do
    subject { {get: "/#{ZomekiCMS::ADMIN_URL_PREFIX}/ad_banner/c1/2/banners"} }
    it { should route_to(controller: 'ad_banner/admin/banners', action: 'index', concept: '1', content: '2') }
  end

  subject { AdBanner::Admin::BannersController }
  it { should < Cms::Controller::Admin::Base }
  it { should include Sys::Controller::Scaffold::Base }

  describe 'GET #index' do
    prepare_first_site
    login_as_site_admin

    it_behaves_like 'routes correct'

    describe 'response' do
      it 'has banner content' do
        content = create(:ad_banner_content_banner)
        get :index, params: {concept: content.concept.id, content: content.id}
        expect(assigns(:content)).to be_kind_of(AdBanner::Content::Banner)
      end
    end
  end
end
