class Sys::Lib::Controller
  class << self
    def dispatch(controller_name, action_name, options)
      controller = "#{controller_name.camelize}Controller".constantize.new
      request = create_request(controller_name, action_name, options)
      response = create_response(request)
      status, headers = controller.dispatch(action_name, request, response)
      return status, headers, response
    end

    def render(controller_name, action_name, options)
      _, _, response = dispatch(controller_name, action_name, options)
      response.body.to_s.html_safe
    end

    private

    def create_request(controller_name, action_name, options)
      options = options.symbolize_keys
      options[:base_url] ||= 'http://127.0.0.1'
      options[:method] ||= 'GET'
      options[:agent_type] ||= :pc

      params = options[:params] || {}
      params = params.to_unsafe_h if params.is_a?(ActionController::Parameters)
      params = params.merge(controller: controller_name, action: action_name)

      request = ActionDispatch::Request.new(Rack::MockRequest.env_for(options[:base_url]))
      request.env["REQUEST_METHOD"] = options[:method]
      request.env['action_dispatch.request.parameters'] = params.symbolize_keys.with_indifferent_access

      if options[:agent_type] == :smart_phone
        jpmobile_envs_for_smart_phone.each do |key, value|
          request.env[key] = value
        end
      end

      request
    end

    def create_response(request)
      response = ActionDispatch::Response.new
      response.request = request
      response
    end

    def jpmobile_envs_for_smart_phone
      user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D201 Safari/9537.53'
      {
        'HTTP_USER_AGENT' => user_agent,
        'rack.jpmobile' => Jpmobile::Mobile::AbstractMobile.carrier('HTTP_USER_AGENT' => user_agent)
      }
    end
  end
end
