require 'rails_helper'

RSpec.describe Core do
  before :all do
    @site = create(:cms_site, :first)
    initialize_core @site.full_uri
  end

  context 'when site_id exist in cookie' do
    before do
      Core.env['HTTP_COOKIE'] = "cms_site=#{@site.id}"
    end

    describe '.get_site_by_cookie' do
      it 'returns site by the id' do
        expect(Core.send(:get_site_by_cookie)).to eq(@site)
      end
    end
  end

  context 'when no site_id exist in cookie' do
    before do
      Core.env['HTTP_COOKIE'] = nil
    end

    describe '.get_site_by_cookie' do
      it 'returns no site' do
        expect(Core.send(:get_site_by_cookie)).to be_nil
      end
    end
  end
end
