class Map::Marker < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::File
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content
  include GpCategory::Model::Rel::Category

  attr_accessor :doc # Not saved to database

  attribute :sort_no, :integer, default: 10

  enum_ish :state, [:public, :closed], default: :public

  # Content
  belongs_to :content, class_name: 'Map::Content::Marker', required: true

  belongs_to :icon_category, class_name: 'GpCategory::Category'

  validates :state, presence: true
  validates :title, presence: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true

  before_save :set_name
  before_destroy :close_files

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true)

  scope :public_state, -> { where(state: 'public') }

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

  def public_smart_phone_path
    return '' unless content.public_node
    "#{content.public_node.public_smart_phone_path}#{name}/"
  end

  def publish_files
    super
    publish_smart_phone_files if content.site.publish_for_smart_phone?
  end

  private

  def set_name
    return if self.name.present?
    date = (created_at || Time.now).strftime('%Y%m%d')
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
          sort_no: doc.marker_sort_no,
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
