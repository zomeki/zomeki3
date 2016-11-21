module CommonHelpers
  module ClassMethods
    def prepare_first_site(path: '/')
      let(:first_site) { create(:cms_site, :first) }
      before do
        uri = "#{first_site.full_uri.to_s.sub(/\/\z/, '')}/#{path.to_s.sub(/\A\//, '')}"
        initialize_core(uri)
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def initialize_core(uri)
    parsed_uri = URI.parse(uri)

    # All of keys are used in lib/core.rb
    env = {'rack.url_scheme' => parsed_uri.scheme,
           'HTTP_X_FORWARDED_HOST' => parsed_uri.host,
           'HTTP_HOST' => parsed_uri.host,
           'REQUEST_URI' => parsed_uri.path,
           'PATH_INFO' => parsed_uri.path,
           'QUERY_STRING' => '',
           'SERVER_PROTOCOL' => 'HTTP/1.1',
           'HTTP_COOKIE' => ''}

    Core.initialize(env)
    Core.recognize_path(env['PATH_INFO'])
  end
end
