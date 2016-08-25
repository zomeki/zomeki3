class Organization::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :organization_group, class_name: 'Organization::Group'
  validates :organization_group_id, presence: true, uniqueness: true

  class << self
    def enqueue_organization_groups(groups)
      enqueue_organization_group_ids(Array(groups).map(&:id))
    end

    def enqueue_organization_group_ids(group_ids)
      ids = Array(group_ids) - self.all.pluck(:organization_group_id)
      ids.each do |id|
        self.create(organization_group_id: id)
      end
    end

    def publish_groups
      self.find_each do |publisher|
        if (og = publisher.organization_group) && og.content && (node = og.content.public_node)
          ::Script.run("organization/script/groups/publish_group?all=all&node_id=#{node.id}&organization_group_id=#{og.id}", force: true)
        end
        publisher.destroy
      end
    end
  end
end
