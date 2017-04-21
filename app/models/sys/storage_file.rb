class Sys::StorageFile < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::TextExtraction

  before_save :set_mime_type

  validates :path, presence: true, uniqueness: true
  validates :available, presence: true
  validate :file_existence

  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where.not(available: true) }
  scope :files_under_directory, ->(dir) {
    where(arel_table[:path].matches("#{dir.to_s.chomp('/')}/%"))
  }

  private

  def file_existence
    errors.add(:base, "File does not exist: #{path}") unless ::File.exists?(path.to_s)
  end

  def set_mime_type
    result = `file -b --mime #{path}`
    self.mime_type = result.split(/[:;]\s+/).first
  rescue => e
    warn_log e.message
  end

  class << self
    def self.import(r = 'sites')
      root = r.start_with?(Rails.root.to_s) ? Pathname.new(r) : Rails.root.join(r.sub(/\A\//, ''))

      if root.file?
        find_or_initialize_by(path: root.to_s).update!(available: true)
      elsif root.directory?
        transaction do
          files_under_directory(root).update_all(available: false)
          Dir.glob(root.join('**/*')) do |file|
            next unless ::File.file?(file)
            find_or_initialize_by(path: file).update!(available: true)
          end
          unavailable.destroy_all
        end
      end
    end
  end
end
