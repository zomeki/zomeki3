class Organization::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :organization_group, class_name: 'Organization::Group'
  validates :organization_group_id, presence: true, uniqueness: true

  class << self
    def register(group_ids)
      return if group_ids.blank?

      ids = Array(group_ids) - self.all.pluck(:organization_group_id)
      return if ids.blank?

      items = ids.map { |id| self.new(organization_group_id: id) }
      self.import(items)

      Organization::PublisherJob.perform_later unless Organization::PublisherJob.queued?
    end
  end
end
