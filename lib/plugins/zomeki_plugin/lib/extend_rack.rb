module Rack
  class Request
    def initialize_with_internal(env)
      unless Core.internal_uri == env['PATH_INFO']
        Core.initialize(env)
        Core.recognize_path(env['PATH_INFO'])
        env['PATH_INFO'] = Core.internal_uri
      end

      initialize_without_internal(env)
    end
    alias_method_chain :initialize, :internal
  end
end
