require 'spec_helper'

describe Rack::Request do
  before do
    Core.user = FactoryGirl.create(:sys_user_system_admin)
    Core.user_group = Core.user.group
    FactoryGirl.create(:cms_site_zomeki_example_com)
    FactoryGirl.create(:cms_node_1)
  end

  describe '.initialize' do
    it 'replaces PATH_INFO to internal' do
      req = Rack::Request.new('HTTP_HOST' => 'zomeki.example.com', 'PATH_INFO' => '/abc')
      expect(req.env['PATH_INFO']).to eq '/_public/cms/node_pages/abc'
    end
  end
end
