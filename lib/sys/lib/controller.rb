class Sys::Lib::Controller
  class << self
    def dispatch(controller_name, action_name, options)
      controller = "#{controller_name.camelize}Controller".constantize.new
      request = create_request(controller_name, action_name, options)
      response = create_response(request)
      status, headers = controller.dispatch(action_name, request, response)
      response
    end

    def render(controller_name, action_name, options)
      response = dispatch(controller_name, action_name, options)
      response.body.to_s.html_safe
    end

    private

    def create_request(controller_name, action_name, options)
      options = options.symbolize_keys
      options[:base_url] ||= options[:request] ? options[:request].url : 'http://127.0.0.1/'
      options[:method] ||= 'GET'

      params = options[:params] || {}
      params = params.to_unsafe_h if params.is_a?(ActionController::Parameters)
      params = params.merge(controller: controller_name, action: action_name)

      request = ActionDispatch::Request.new(Rack::MockRequest.env_for(options[:base_url]))
      request.env['REQUEST_METHOD'] = options[:method]
      request.env['action_dispatch.request.parameters'] = params.symbolize_keys.with_indifferent_access

      if options[:request]
        ['HTTP_USER_AGENT',
         'rack.jpmobile',
         'rack.session',
         'rack.request.cookie_hash',
         'action_dispatch.cookies'].each do |key|
          request.env[key] = options[:request].env[key]
        end
      end

      if (agent = pseudo_agent(options[:agent_type]))
        request.env['HTTP_USER_AGENT'] = agent
        request.env['rack.jpmobile'] = Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => agent)
      end

      request
    end

    def create_response(request)
      response = ActionDispatch::Response.new
      response.request = request
      response
    end

    def pseudo_agent(agent_type)
      case agent_type
      when :pc
        'Mozilla/5.0'
      when :mobile
        'DoCoMo/2.0'
      when :smart_phone
        'Mozilla/5.0 (iPhone)'
      end
    end
  end
end
