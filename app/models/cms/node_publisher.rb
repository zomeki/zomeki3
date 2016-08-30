class Cms::NodePublisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :node
  validates :node_id, presence: true, uniqueness: true

  class << self
    def register(node_ids)
      return if node_ids.blank?

      ids = Array(node_ids) - self.all.pluck(:node_id)
      return if ids.blank?

      items = ids.map { |id| self.new(node_id: id) }
      self.import(items)

      Cms::NodePublisherJob.perform_later unless Cms::NodePublisherJob.queued?
    end
  end
end
