module Rack
  module Session
    module Abstract
      class ID
        def call_with_internal(env)
          Core.initialize(env)
          Core.recognize_path(env['PATH_INFO'])
          env['PATH_INFO'] = Core.internal_uri

          call_without_internal(env)
        end
        alias_method_chain :call, :internal
      end
    end
  end
end
