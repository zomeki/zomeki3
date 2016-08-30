class Cms::Publisher < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :publishable, polymorphic: true

  validates :publishable_id, uniqueness: { scope: [:publishable_type, :state] }

  class << self
    def register(items)
      items = Array(items)
      return if items.blank?

      pubs = items.map { |item| self.new(publishable: item) }
      self.import(pubs)

      Cms::PublisherJob.perform_later unless Cms::PublisherJob.queued?
    end
  end
end
