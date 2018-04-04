module Cms::Model::Base::Node
  def states
    [['公開','public'],['非公開','closed']]
  end

  def public?
    return state == 'public' && !published_at.blank?
  end

  def content_name
    return content.name if content
    Cms::Lib::Modules.module_name(:cms)
  end

  def content_model_name(option = nil)
    name = Cms::Lib::Modules.model_name(:node, model).to_s
    case option
    when :short, :wo_content
      name.gsub(/^.*?\//, '')
    when :wo_type
      names = name.split('/')
      "#{names.first}/#{names.last}"
    else
      name
    end
  end

  def model_type
    return nil unless mod = Cms::Lib::Modules.find(:node, model)
    mod.type
  end

  def admin_controller
    model.to_s.tableize.sub('/', '/admin/node/')
  end

  def admin_uri(options = {})
    Rails.application.routes.url_helpers.url_for({ controller: admin_controller,
                                                   action: :show,
                                                   concept: concept,
                                                   parent: parent_id,
                                                   id: id,
                                                   only_path: true }.merge(options))
  rescue ActionController::UrlGenerationError => e
    warn_log e
    nil
  end

  def routes
    loop      = 0
    exists    = [self.id]
    routes    = [self]
    parent_id = route_id
    while (current = self.class.find_by(id: parent_id))
      break if exists.index(current.id)
      exists << current.id

      routes.unshift(current)
      parent_id = current.route_id
      break if parent_id == 0
      break if loop > 20
      loop += 1
    end if id != parent_id
    [routes]
  end

  def bread_crumbs(node = nil, options = {})
    crumbs = []
    node ||= self
    node.routes.each do |r|
      c = []
      r.each do |i|
        uri = options[:full_uri] ? i.public_full_uri : i.public_uri
        c << [i.title, uri]
      end
      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
