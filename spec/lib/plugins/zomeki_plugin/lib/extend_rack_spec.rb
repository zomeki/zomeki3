require 'spec_helper'

# see rack-1.5.2/lib/rack/session/abstract/id.rb

describe Rack::Session::Abstract::ID do
  before do
    Core.user = FactoryGirl.create(:sys_user_system_admin)
    Core.user_group = Core.user.group
    FactoryGirl.create(:cms_site_zomeki_example_com)
    FactoryGirl.create(:cms_node_1)
  end

  describe '#call' do
    it 'replaces PATH_INFO to internal' do
      env = Rack::MockRequest.env_for('http://zomeki.example.com/abc')
      id = Rack::Session::Abstract::ID.new(->(inner_env) { [200, {'Content-Type' => 'text/plain'}, ['Hello World']] }, env)
      id.call(env)

      expect(env['PATH_INFO']).to eq '/_public/cms/node_pages/abc'
    end
  end
end
