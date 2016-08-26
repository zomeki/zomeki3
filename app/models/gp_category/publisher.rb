class GpCategory::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :category
  validates :category_id, presence: true, uniqueness: true

  class << self
    def queue_name
      self.table_name
    end

    def queued?
      Delayed::Job.where(queue: queue_name, locked_at: nil).exists?
    end

    def register(category_ids)
      return if category_ids.blank?

      ids = Array(category_ids) - self.all.pluck(:category_id) 
      return if ids.blank?

      items = ids.map { |id| self.new(category_id: id) }
      self.import(items)
      self.delay(queue: queue_name).perform unless queued? 
    end

    def perform
      category_ids = {}
      self.all.each do |publisher|
        unless (c = publisher.category)
          publisher.destroy
          next
        end
        category_ids[c.content.id] ||= {}
        category_ids[c.content.id][c.category_type.id] ||= []
        category_ids[c.content.id][c.category_type.id] << c.id
      end

      category_ids.each do |key, value|
        value.each do |k, v|
          ids = v.map{|c| "target_child_id[]=#{c}" }.join('&')
          script_params = "target_module=gp_category&target_content_id[]=#{key}&target_id[]=#{k}&#{ids}"
          self.where(category_id: v).destroy_all
          ::Script.run("cms/script/nodes/publish?all=all&#{script_params}", force: true)
        end
      end
    end
  end
end
