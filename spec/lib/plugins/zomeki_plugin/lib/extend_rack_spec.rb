require 'spec_helper'

# see rack-1.5.2/test/spec_lock.rb

class Lock
  attr_reader :synchronized

  def initialize
    @synchronized = false
  end

  def synchronize
    @synchronized = true
    yield
  end

  def lock
    @synchronized = true
  end

  def unlock
    @synchronized = false
  end
end

describe Rack::Lock do
  before do
    Core.user = FactoryGirl.create(:sys_user_system_admin)
    Core.user_group = Core.user.group
    FactoryGirl.create(:cms_site_zomeki_example_com)
    FactoryGirl.create(:cms_node_1)
  end

  describe '#call' do
    it 'replaces PATH_INFO to internal' do
      lock = Lock.new
      res = ['Hello World']
      app = Rack::Lock.new(lambda { |inner_env| [200, {"Content-Type" => "text/plain"}, res] }, lock)

      env = Rack::MockRequest.env_for('http://zomeki.example.com/abc')
      app.call(env)

      expect(env['PATH_INFO']).to eq '/_public/cms/node_pages/abc'
    end
  end
end
