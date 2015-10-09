# encoding: utf-8
class Tool::ConvertDoc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  belongs_to :content, :class_name => 'Cms::Content'
  belongs_to :docable, polymorphic: true

  scope :search_with_criteria, ->(criteria = {}) {
    rel = all
    if criteria && criteria[:keyword].present?
      rel = rel.search_with_text(:title, :uri_path, :doc_name, :doc_public_uri, :body, criteria[:keyword])
    end
    rel
  }

  def doc
    docable
  end

  def latest_doc
    return nil unless docable_type
    return @latest_doc if @latest_doc
    @latest_doc = docable_type.constantize.where(name: doc_name).order(updated_at: :desc).first
  end

  def source_uri
    "http://#{uri_path.to_s.gsub(/.htm.html$/, '.htm')}"
  end
end
