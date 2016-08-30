class GpCategory::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :category
  validates :category_id, presence: true, uniqueness: true

  class << self
    def register(category_ids)
      return if category_ids.blank?

      ids = Array(category_ids) - self.all.pluck(:category_id) 
      return if ids.blank?

      items = ids.map { |id| self.new(category_id: id) }
      self.import(items)

      GpCategory::PublisherJob.perform_later unless GpCategory::PublisherJob.queued?
    end
  end
end
