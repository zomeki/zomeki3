module Cms::Model::Rel::Content
  extend ActiveSupport::Concern

  included do
    belongs_to :content, class_name: 'Cms::Content'
    delegate :site, to: :content
    delegate :site_id, to: :content
    nested_scope :in_site, through: :content
  end

  def inherited_concept
    (respond_to?(:concept) && concept) || content.inherited_concept
  end

  def admin_uri(options = {})
    controller = self.class.name.tableize.sub('/', '/admin/')
    Rails.application.routes.url_helpers.url_for({ controller: controller,
                                                   action: :show,
                                                   content: content,
                                                   concept: content.concept,
                                                   id: id,
                                                   only_path: true }.merge(options))
  rescue ActionController::UrlGenerationError => e
    error_log e
    nil
  end
end
