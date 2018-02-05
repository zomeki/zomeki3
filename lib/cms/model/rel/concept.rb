module Cms::Model::Rel::Concept
  extend ActiveSupport::Concern

  included do
    belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'
  end

  def admin_uri(options = {})
    controller = self.class.name.tableize.sub('/', '/admin/')
    Rails.application.routes.url_helpers.url_for({ controller: controller,
                                                   action: :show,
                                                   concept: concept,
                                                   id: id,
                                                   only_path: true }.merge(options))
  rescue ActionController::UrlGenerationError => e
    error_log e
    nil
  end
end
