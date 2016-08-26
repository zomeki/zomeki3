class Organization::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :organization_group, class_name: 'Organization::Group'
  validates :organization_group_id, presence: true, uniqueness: true

  class << self
    def queue_name
      self.table_name
    end

    def queued?
      Delayed::Job.where(queue: queue_name, locked_at: nil).exists?
    end

    def register(group_ids)
      return if group_ids.blank?

      ids = Array(group_ids) - self.all.pluck(:organization_group_id)
      return if ids.blank?

      items = ids.map { |id| self.new(organization_group_id: id) }
      self.import(items)
      self.delay(queue: queue_name).perform unless queued?
    end

    def perform
      self.find_each do |item|
        item.destroy
        if (og = item.organization_group) && og.content && (node = og.content.public_node)
          ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}&organization_group_id=#{og.id}", force: true)
        end
      end
    end
  end
end
