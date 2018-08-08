class Sys::Admin::RedirectController < Cms::Controller::Admin::Base
  def pre_dispatch
    model = params[:model].to_s.safe_constantize
    return redirect_to admin_root_path unless model

    @item = model.find_by(id: params[:id])
    return redirect_to admin_root_path unless @item
  end

  def index
    options = recognize_url_options
    Core.set_concept(options[:concept]) if options[:concept]
    redirect_to url_for(options)
  rescue ActionController::UrlGenerationError
    redirect_to admin_root_path
  end

  private

  def recognize_url_options
    options = recognize_controller
    options[:action] ||= 'show'
    options[:id] ||= @item.id

    recognize_spec_options(options)

    if @item.respond_to?(:site) && @item.site && @item.site.admin_full_uri.present?
      options.merge!(host: @item.site.admin_full_uri.chomp('/'), only_path: false)
    end

    options
  end

  def recognize_controller
    case @item
    when Cms::Piece
      { controller: @item.model.underscore.pluralize.sub('/', '/admin/piece/') }
    when Cms::Node
      { controller: @item.model.underscore.pluralize.sub('/', '/admin/node/') }
    else
      { controller: @item.class.name.underscore.pluralize.sub('/', '/admin/') }
    end
  end

  def recognize_spec_options(options)
    spec = find_spec_from_controller_action(options[:controller], options[:action])
    return unless spec

    spec.scan(/:(\w+)/).flatten.each_with_object({}) do |part, _|
      case part
      when 'concept'
        options[:concept] ||= recognize_concept
      else
        options[part.to_sym] ||= recognize_others(part)
      end
    end
  end

  def recognize_concept
    if @item.respond_to?(:content) && @item.class.name !~ /^(Cms|Sys)::/
      @item.content.concept
    elsif @item.respond_to?(:concept)
      @item.concept
    end
  end

  def recognize_others(part)
    parts = [part]
    parts << part.sub(/_id$/, '') if part =~ /_id$/
    parts.each do |p|
      return @item.public_send(p) if @item.respond_to?(p)
    end
    nil
  end

  def find_spec_from_controller_action(controller, action)
    Rails.application.routes.routes.each do |route|
      if route.requirements[:controller] == controller && route.requirements[:action] == action
        return route.path.spec.to_s
      end
    end
    nil
  end
end
