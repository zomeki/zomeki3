class GpArticle::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :doc
  validates :doc_id, presence: true, uniqueness: true

  class << self
    def enqueue_docs(docs)
      enqueue_doc_ids(Array(docs).map(&:id))
    end

    def enqueue_doc_ids(doc_ids)
      ids = Array(doc_ids) - self.all.pluck(:doc_id)
      ids.each do |id|
        self.create(doc_id: id)
      end
    end

    def publish_docs
      self.find_each do |publisher|
        if (doc = publisher.doc) && doc.content && (node = doc.content.public_node)
          ::Script.run("gp_article/script/docs/publish_doc?all=all&node_id=#{node.id}&doc_id=#{doc.id}", force: true)
        end
        publisher.destroy
      end
    end
  end
end
