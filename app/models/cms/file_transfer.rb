class Cms::FileTransfer < ApplicationRecord
  include Sys::Model::Base

  STATE_OPTIONS = [['待機中','queued'],['実行中','performing']]

  validates :path, presence: true
  validate :validate_queue, on: :create

  scope :queued_items, -> {
    where([
      arel_table[:state].eq('queued'),
      [arel_table[:state].eq('performing'), arel_table[:updated_at].lt(Time.now - 3.hours)].reduce(:and)
    ].reduce(:or))
  }

  private

  def validate_queue
    if self.class.where(state: 'queued', site_id: site_id, path: path, recursive: recursive).exists?
      errors.add(:path, :taken)
    end
  end

  class << self
    def register(site_id, paths, options = {})
      paths = Array(paths)
      return if paths.blank?

      items = paths.map do |path|
        path = if path.end_with?('/') && File.exist?(path)
                 path
               else
                 "#{File.dirname(path)}/"
               end
        item = self.new(state: 'queued', site_id: site_id)
        item.path = path.sub(%r|^#{Rails.root}/|, '').sub(%r|^\./|, '')
        item.priority = priority_from_path(path)
        item.recursive = options[:recursive]
        item
      end
      self.import(items)

      Cms::FileTransferJob.perform_later unless Cms::FileTransferJob.queued?
    end

    def priority_from_path(path)
      if path =~ %r|^sites/\d+/upload/|
        10
      else
        20
      end
    end
  end
end
