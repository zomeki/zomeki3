module Cms::Model::Base::Piece
  def states
    [['公開','public'],['非公開','closed']]
  end
  
  def public?
    return state == "public"
  end

  def content_name
    return content.name if content
    Cms::Lib::Modules.module_name(:cms)
  end

  def module_name(option = nil)
    name = Cms::Lib::Modules.model_name(:piece, model)
    return name.to_s.gsub(/^.*?\//, '') if option == :short
    name
  end

  def admin_controller
    model.to_s.underscore.pluralize.sub('/', '/admin/piece/')
  end

  def admin_uri
    controller = model.to_s.underscore.pluralize.gsub(/^(.*?)\//, "\\1/c#{concept_id}/piece_") + "/#{id}"
    "#{Core.uri}#{ZomekiCMS::ADMIN_URL_PREFIX}/#{controller}"
  end

  def edit_admin_uri
    "#{admin_uri}/edit"
  end
end
