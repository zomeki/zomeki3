class GpArticle::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :doc
  validates :doc_id, presence: true, uniqueness: true

  class << self
    def queue_name
      self.table_name
    end

    def queued?
      Delayed::Job.where(queue: queue_name, locked_at: nil).exists?
    end

    def register(doc_ids)
      return if doc_ids.blank?

      ids = Array(doc_ids) - self.all.pluck(:doc_id)
      return if ids.blank?

      items = ids.map { |id| self.new(doc_id: id) }
      self.import(items)
      self.delay(queue: queue_name).perform unless queued?
    end

    def perform
      self.find_each do |item|
        item.destroy
        if (doc = item.doc) && doc.content && (node = doc.content.public_node)
          ::Script.run("gp_article/script/docs/publish_doc?all=all&node_id=#{node.id}&doc_id=#{doc.id}", force: true)
        end
      end
    end
  end
end
