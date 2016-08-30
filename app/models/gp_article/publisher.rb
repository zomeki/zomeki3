class GpArticle::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :doc
  validates :doc_id, presence: true, uniqueness: true

  class << self
    def register(doc_ids)
      return if doc_ids.blank?

      ids = Array(doc_ids) - self.all.pluck(:doc_id)
      return if ids.blank?

      items = ids.map { |id| self.new(doc_id: id) }
      self.import(items)

      GpArticle::PublisherJob.perform_later unless GpArticle::PublisherJob.queued?
    end
  end
end
