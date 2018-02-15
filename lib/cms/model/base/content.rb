module Cms::Model::Base::Content
  def module_name(option = nil)
    name = Cms::Lib::Modules.model_name(:content, model)
    return name.to_s.gsub(/.*\//, '') if option == :short
    name
  end

  def admin_uri(options = {})
    controller = model.tableize.sub('/', '/admin/')
    Rails.application.routes.url_helpers.url_for({ controller: controller,
                                                   action: :index,
                                                   concept: concept,
                                                   content: self,
                                                   only_path: true }.merge(options))
  rescue ActionController::UrlGenerationError => e
    error_log e
    nil
  end

  def admin_content_uri(options = {})
    controller = model.tableize.split('/').first + '/admin/content/base'
    Rails.application.routes.url_helpers.url_for({ controller: controller,
                                                   action: :show,
                                                   concept: concept,
                                                   id: self,
                                                   only_path: true }.merge(options))
  rescue ActionController::UrlGenerationError => e
    error_log e
    nil
  end
end
