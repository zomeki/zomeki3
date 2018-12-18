class Cms::DataFileNode < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  has_many :files, foreign_key: :node_id, class_name: 'Cms::DataFile'

  validates :concept_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :concept_id, case_sensitive: false }
  validate :validate_name

  after_save     Cms::Publisher::BracketeeCallbacks.new, if: :saved_changes?
  before_destroy Cms::Publisher::BracketeeCallbacks.new, prepend: true

  after_destroy :remove_files

  def label(separator = " : ")
    label = name
    unless title.blank?
      label += "#{separator}#{title}"
    end
    label
  end

  def validate_name
    return if Zomeki.config.application['upload.allow_japanese_filename']
    if !name.blank?
      if name !~ /^[0-9a-zA-Z_\-]+$/
        errors.add :name, "は半角英数字を入力してください。"
      end
    end
  end

  def changed_bracket_names
    names = [name, name_before_last_save].select(&:present?).uniq
    names.map { |name| files.map { |file| "file/#{name}/#{file.name}" } }.flatten
  end

private
  def remove_files
    files.each {|file| file.destroy }
    return true
  end
end
