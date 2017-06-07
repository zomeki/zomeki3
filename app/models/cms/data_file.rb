class Cms::DataFile < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Bracketee
  include Cms::Model::Auth::Concept::Creator

  include StateText

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :site   , :foreign_key => :site_id   , :class_name => 'Cms::Site'
  belongs_to :node   , :foreign_key => :node_id   , :class_name => 'Cms::DataFileNode'

  after_save     Cms::Publisher::BracketeeCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::BracketeeCallbacks.new

  before_destroy :close

  define_model_callbacks :publish_files, :close_files
  after_publish_files FileTransferCallbacks.new(:public_path, recursive: true)
  after_close_files FileTransferCallbacks.new(:public_path, recursive: true)

  scope :public_state, -> { where(state: 'public') }

  def self.find_by_public_path(path)
    site_id, id, name = path.match(%r!/sites[/\d]*/(\d+)/public/_files/(\d+)/(.+)\z!i).captures
    return nil unless site_id && id && name
    Cms::DataFile.find_by(id: id[0..-2], name: name, site_id: site_id)
  end

  def public_path
    return nil unless site
    dir = Util::String::CheckDigit.check(format('%07d', id))
    "#{site.public_path}/_files/#{dir}/#{escaped_name}"
  end

  def public_thumbnail_path
    "#{::File.dirname(public_path)}/thumb/#{escaped_name}"
  end

  def public_uri
    dir = Util::String::CheckDigit.check(format('%07d', id))
    "/_files/#{dir}/#{escaped_name}"
  end

  def public_thumbnail_uri
    uri = public_uri
    "#{::File.dirname(uri)}/thumb/#{::File.basename(uri)}"
  end

  def public_full_uri
    "#{site.full_uri}#{public_uri.sub(/^\//, '')}"
  end

  def public_thumbnail_full_uri
    "#{site.full_uri}#{public_thumbnail_uri.sub(/^\//, '')}"
  end

  def publishable?
    return false unless editable?
    return !public?
  end

  def closable?
    return false unless editable?
    return public?
  end

  def public?
    return published_at != nil
  end

  def publish(options = {})
    unless FileTest.exist?(upload_path)
      errors.add :base, 'ファイルデータが見つかりません。'
      return false
    end
    self.state        = 'public'
    self.published_at = Core.now
    return false unless save(:validate => false)

    run_callbacks :publish_files do
      remove_public_file
      upload_public_file
    end
  end

  def close
    self.state        = 'closed'
    self.published_at = nil
    return false unless save(:validate => false)

    run_callbacks :close_files do
      remove_public_file
    end
  end

  def duplicated?
    file = self.class.ci_match(name: name).where(concept_id: concept_id).where(node_id: node_id ? node_id : nil)
    file = file.where.not(id: id) if id
    file.exists?
  end

  def remove_old_name_public_file(old_name)
    public_dir = ::File.dirname(public_path)
    old_path = "#{public_dir}/#{old_name}"
    old_thumb_path = "#{public_dir}/thumb/#{old_name}"
    ::Storage.rm_rf(old_path) if ::Storage.exists?(old_path)
    ::Storage.rm_rf(old_thumb_path) if ::Storage.exists?(old_thumb_path)
  end

  def remove_public_file
    FileUtils.remove_entry_secure(public_path) if FileTest.exist?(public_path)
    FileUtils.remove_entry_secure(public_thumbnail_path) if FileTest.exist?(public_thumbnail_path)
    return true
  end

  def upload_public_file
    Util::File.put(public_path, src: upload_path, mkdir: true) if FileTest.exist?(upload_path)
    Util::File.put(public_thumbnail_path, src: upload_path(type: :thumb), mkdir: true) if FileTest.exist?(upload_path(type: :thumb))
    return true
  end
end
