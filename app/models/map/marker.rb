class Map::Marker < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::File
  include Cms::Model::Auth::Content
  include GpCategory::Model::Rel::Category

  include StateText

  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Map::Content::Marker'
  validates :content_id, :presence => true

  # Proper
  validates_presence_of :state

  validates :title, :presence => true
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true

  after_initialize :set_defaults
  before_save :set_name

  after_save     Cms::Publisher::ContentRelatedCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::ContentRelatedCallbacks.new

  scope :public_state, -> { where(state: 'public') }

  belongs_to :icon_category, :class_name => 'GpCategory::Category'
  attr_accessor :doc # Not saved to database

  def public_uri
    return '' unless content.public_node
    "#{content.public_node.public_uri}#{name}/"
  end

  def public_file_uri
    return '' if public_uri.blank? || files.empty?
    "#{public_uri}file_contents/#{files.first.name}"
  end

  def public_path
    return '' unless content.public_node
    "#{content.public_node.public_path}#{name}/"
  end

  def public_file_path
    return '' if public_path.blank? || files.empty?
    "#{public_path}file_contents/#{files.first.name}"
  end

  def public_smart_phone_path
    return '' unless content.public_node
    "#{content.public_node.public_smart_phone_path}#{name}/"
  end

  def public_smart_phone_file_path
    return '' if public_smart_phone_path.blank? || files.empty?
    "#{public_smart_phone_path}file_contents/#{files.first.name}"
  end

  private

  def set_defaults
    self.state ||= STATE_OPTIONS.first.last if self.has_attribute?(:state)
    self.target ||= TARGET_OPTIONS.first.last if self.has_attribute?(:target)
  end

  def set_name
    return if self.name.present?
    date = if created_at
             created_at.strftime('%Y%m%d')
           else
             Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
           end
    seq = Util::Sequencer.next_id('map_markers', version: date, site_id: content.site_id)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  class << self
    def from_doc(doc)
      return [] unless doc.maps.first

      doc.maps.first.markers.map do |m|
        marker = self.new(
          title: doc.title,
          latitude: m.lat,
          longitude: m.lng,
          window_text: %Q(<p>#{m.name}</p><p><a href="#{doc.public_uri}">詳細</a></p>),
          doc: doc,
          created_at: doc.display_published_at,
          updated_at: doc.display_published_at
        )
        marker.categories = doc.marker_categories
        marker.files = doc.files
        marker.icon_category = doc.marker_icon_category
        marker.readonly!
        marker
      end
    end
  end
end
