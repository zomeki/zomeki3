class Cms::SearchIndexer < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  belongs_to :indexable, polymorphic: true

  validate :validate_queue, on: :create

  private

  def validate_queue
    if self.class.where(state: 'queued', site_id: site_id, indexable: indexable).exists?
      errors.add(:indexable, :taken)
    end
  end

  class << self
    def register(site_id, items)
      items = Array(items)
      return if items.blank?

      pubs = items.map do |item|
               pub = self.new(site_id: site_id, indexable: item, state: 'queued')
               pub.priority = 10
               pub
             end
      self.import(pubs)
    end
  end
end
