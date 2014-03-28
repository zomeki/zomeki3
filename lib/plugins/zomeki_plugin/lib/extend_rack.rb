module Rack
  class Request
    def initialize_with_internal(env)
      Core.initialize(env)
      Core.recognize_path(env['PATH_INFO'])
      env['PATH_INFO'] = Core.internal_uri

      initialize_without_internal(env)
    end
    alias_method_chain :initialize, :internal
  end
end
