require 'spec_helper'

describe Core do
  before do
    Core.initialize({})
    Core.user = fg_find_or_create(:sys_user_system_admin)
    Core.user_group = Core.user.groups.first
    @site = fg_find_or_create(:cms_site_first_example_com)
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
    describe '.get_site_by_cookie' do
      it 'returns no site' do
        expect(Core.send(:get_site_by_cookie)).to be_nil
      end
    end
  end
end
