class Cms::NodePublisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :node
  validates :node_id, presence: true, uniqueness: true

  class << self
    def enqueue_nodes(nodes)
      register_node_ids(Array(nodes).map(&:id))
    end

    def enqueue_node_ids(node_ids)
      ids = Array(node_ids) - self.all.pluck(&:node_id) 
      ids.each do |id|
        self.create(node_id: id)
      end
    end

    def publish_nodes
      self.find_each do |publisher|
        ::Script.run("cms/script/nodes/publish?all=all&target_module=cms&target_node_id=#{publisher.node_id}", force: true)
        publisher.destroy
      end
    end
  end
end
