module GpArticle::Model::Rel::Directory
  extend ActiveSupport::Concern

  included do
    has_many :url_directories, class_name: 'GpArticle::Directory', dependent: :destroy, as: :publishable
    after_save :set_public_name
  end

private

  def set_public_name
    return unless state_public?
    rel = url_directories.first || url_directories.build({content_id: content_id})
    rel.name = "#{public_uri(without_filename: true)}#{filename_base}.html"
    rel.save
  end

end
