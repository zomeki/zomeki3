module Cms::Model::Base::Content
  def states
    [['公開','public'],['非公開','closed']]
  end

  def module_name(option = nil)
    name = Cms::Lib::Modules.model_name(:content, model)
    return name.to_s.gsub(/.*\//, '') if option == :short
    name
  end

  def public_path
    id_dir  = Util::String::CheckDigit.check(format('%07d', id)).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    "#{site.public_path}/_contents/#{id_dir}"
  end

  def public_uri(class_name)
    return nil unless node = Cms::Node.where(content_id: id, model: class_name.to_s).order(:id).first
    node.public_uri
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
