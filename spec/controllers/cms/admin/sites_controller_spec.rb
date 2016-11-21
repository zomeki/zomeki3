require 'rails_helper'

RSpec.describe Cms::Admin::SitesController, type: :controller do
  shared_examples_for 'routes correct' do
    subject { {get: "/#{ZomekiCMS::ADMIN_URL_PREFIX}/cms/sites/new"} }
    it { should route_to(controller: 'cms/admin/sites', action: 'new') }
  end

  prepare_first_site

  context "when user doesn't have site_creatable" do
    login_as_site_admin

    describe 'GET #new' do
      before do
        get 'new'
      end

      it_behaves_like 'routes correct'

      describe 'response' do
        subject { response }
        it { should_not be_success }
      end
    end
  end

  context 'when user haves site_creatable' do
    login_as_system_admin

    describe 'GET #new' do
      before do
        get 'new'
      end

      it_behaves_like 'routes correct'

      describe 'response' do
        subject { response }
        it { should be_success }
      end
    end
  end
end
