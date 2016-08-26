class Cms::NodePublisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :node
  validates :node_id, presence: true, uniqueness: true

  class << self
    def queue_name
      self.table_name
    end

    def queued?
      Delayed::Job.where(queue: queue_name, locked_at: nil).exists?
    end

    def register(node_ids)
      return if node_ids.blank?

      ids = Array(node_ids) - self.all.pluck(:node_id)
      return if ids.blank?

      items = ids.map { |id| self.new(node_id: id) }
      self.import(items)
      self.delay(queue: queue_name).perform unless queued?
    end

    def perform
      self.find_each do |item|
        item.destroy
        ::Script.run("cms/script/nodes/publish?all=all&target_module=cms&target_node_id=#{item.node_id}", force: true)
      end
    end
  end
end
