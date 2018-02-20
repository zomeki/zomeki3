class Sys::StorageFile < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::TextExtraction

  before_save :set_mime_type

  after_save     Cms::SearchIndexerCallbacks.new, if: :changed?
  before_destroy Cms::SearchIndexerCallbacks.new

  validates :path, presence: true, uniqueness: true
  validates :available, presence: true
  validate :file_existence

  scope :in_site, ->(site) { where(arel_table[:path].matches("#{Rails.root}/sites/#{format('%04d', site.id)}/%")) }
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where.not(available: true) }
  scope :files_under_directory, ->(dir) {
    where(arel_table[:path].matches("#{dir.to_s.chomp('/')}/%"))
  }

  def site_id
    path.scan(%r|#{Rails.root.join('sites')}/(\d+)/|).flatten.first.try(:to_i)
  end

  def state
    path =~ %r|#{Rails.root.join('sites')}/\d+/public/| ? 'public' : 'closed'
  end

  def state_was
    nil
  end

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
    def import(r = 'sites')
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
