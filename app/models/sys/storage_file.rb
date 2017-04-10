class Sys::StorageFile < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::TextExtraction

  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where.not(available: true) }
  scope :files_under_directory, ->(dir) {
    where(arel_table[:path].matches("#{dir.to_s.chomp('/')}/%"))
  }

  validates :path, presence: true, uniqueness: true
  validates :available, presence: true

  validate :file_existence

  before_save :set_mime_type

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

  def self.mv(src, dst)
    transaction do
      if ::File.directory?(dst)
        files_under_directory(src).replace_for_all(:path, src.chomp('/'), dst.chomp('/'))
      else
        find_by(path: dst).try!(:destroy!)
        find_by(path: src).try!(:update!, path: dst)
      end
    end
  end

  def self.cp(src, dst)
    transaction do
      find_by(path: dst).try!(:destroy!)
      create!(path: dst)
    end
  end

  def self.rm_rf(path)
    unless ::File.exists?(path.to_s)
      where(arel_table[:path].eq(path).or(arel_table[:path].matches("#{path.sub(/\/\z/, '')}/%"))).destroy_all
    else
      if ::File.directory?(path) || path.end_with?('/')
        files_under_directory(path).destroy_all
      else
        where(path: path).destroy
      end
    end
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
end
