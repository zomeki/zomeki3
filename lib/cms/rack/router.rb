class Cms::Rack::Router
  def initialize(app)
    @app = app
  end

  def call(env)
    Core.initialize(env)
    Core.recognize_path(env['PATH_INFO'])
    env['PATH_INFO'] = Core.internal_uri

    @app.call(env)
  end
end
