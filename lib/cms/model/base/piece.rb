module Cms::Model::Base::Piece
  def public?
    state == "public"
  end

  def module_name(option = nil)
    name = Cms::Lib::Modules.model_name(:piece, model)
    return name.to_s.gsub(/^.*?\//, '') if option == :short
    name
  end

  def admin_controller
    model.to_s.tableize.sub('/', '/admin/piece/')
  end

  def admin_uri(options = {})
    Rails.application.routes.url_helpers.url_for({ controller: admin_controller,
                                                   action: :show,
                                                   concept: concept,
                                                   id: id,
                                                   only_path: true }.merge(options))
  rescue ActionController::UrlGenerationError => e
    warn_log e
    nil
  end
end
