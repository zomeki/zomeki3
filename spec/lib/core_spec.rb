require 'rails_helper'

RSpec.describe Core do
  prepare_first_site

  context 'when site_id exist in cookie' do
    before do
      Core.env['HTTP_COOKIE'] = "cms_site=#{first_site.id}"
    end

    describe '.get_site_by_cookie' do
      it 'returns site by the id' do
        expect(Core.send(:get_site_by_cookie)).to eq first_site
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
