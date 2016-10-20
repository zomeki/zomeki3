module Cms
  module Rack
    class Router
      def initialize(app)
        @app = app
      end

      def call(env)
        rewrite(env)
        Core.initialize(env)
        Core.recognize_path(env['PATH_INFO'])
        env['PATH_INFO'] = Core.internal_uri

        @app.call(env)
      end

      private

      def rewrite(env)
        env['PATH_INFO'].gsub!(%r{/_(mobile|smartphone)}, '')
      end
    end
  end
end

Rails.application.config.middleware.use Cms::Rack::Router
