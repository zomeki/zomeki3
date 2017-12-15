module Util::Route

  class << self
    def recognize_path(node)
      opt = Rails.application.routes.recognize_path(node) unless opt
       if opt[:controller] == 'cms/public/exception'
        Sys::Plugin.enabled_contents.each do |p|
          begin
            opt = p.engine_class_name.constantize.routes.recognize_path(node)
          rescue
            next
          end
        end
      end
      opt
    end
  end

end