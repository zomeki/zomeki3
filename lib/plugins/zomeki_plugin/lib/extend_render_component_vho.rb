# encoding: utf-8
require 'render_component'

module RenderComponent
  module Components
    module ClassMethods
      # Track parent controller to identify component requests
      def process_with_components(request, action, parent_controller = nil) #:nodoc:
        controller = new
        controller.parent_controller = parent_controller
        #-- start patch
        status, headers, body = controller.dispatch(action, request)
        return status, headers, controller.response
        #-- end patch
      end
    end

    module InstanceMethods

      protected
        # Renders the component specified as the response for the current method
        def render_component(options) #:doc:
          component_logging(options) do
            response = component_response(options, true)[2]
            if response.redirect_url
              redirect_to response.redirect_url
            else
              render :text => response.body, :status => response.status
              #-- start patch
              response
              #-- end patch
            end
          end
        end

      private
        def component_response(options, reuse_response)
          options[:controller] = options[:controller].to_s if options[:controller] && options[:controller].is_a?(Symbol)
          klass = component_class(options)
          component_request  = request_for_component(klass.controller_path, options)
          #-- start patch
          if jpmobile = options[:jpmobile]
            component_request.env['HTTP_USER_AGENT'] = jpmobile['HTTP_USER_AGENT']
            component_request.env['rack.jpmobile'] = jpmobile['rack.jpmobile']
          end
          #-- end patch
          # needed ???
          #if reuse_response
            #component_request.env["action_controller.instance"].instance_variable_set :@_response, request.env["action_controller.instance"].instance_variable_get(:@_response)
          #end
          klass.process_with_components(component_request, options[:action], self)
        end

        # Create a new request object based on the current request.
        # NOT IMPLEMENTED FOR RAILS 3 SO FAR: The new request inherits the session from the current request,
        # bypassing any session options set for the component controller's class
        def request_for_component(controller_path, options)
          if options.is_a? Hash
            old_style_params = options.delete(:params)
            options.merge!(old_style_params) unless old_style_params.nil?

            request_params = options.symbolize_keys
            request_env = {}

            request.env.select {|key, value| key == key.upcase || key == 'rack.input'}.each {|item| request_env[item[0]] = item[1]}

            #-- start patch
            #request_env['REQUEST_URI'] = url_for(options)
            #request_env["PATH_INFO"] = url_for(options.merge(:only_path => true))
            #-- end patch
            request_env["action_dispatch.request.symbolized_path_parameters"] = request_params
            request_env["action_dispatch.request.parameters"] = request_params.with_indifferent_access
            request_env["action_dispatch.request.path_parameters"] = Hash[request_params.select{|key, value| [:controller, :action].include?(key)}].with_indifferent_access
            request_env["warden"] = request.env["warden"] if (request.env.has_key?("warden"))
            component_request = ActionDispatch::Request.new(request_env)

            # its an internal request request forgery protection has to be disabled
            # because otherwise forgery detection might raise an error
            component_request.instance_eval do
              def forgery_whitelisted?
                true
              end
            end
            component_request
          else
            request
          end
        end

    end
  end
end
