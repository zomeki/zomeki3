module Cms::Model::Rel::Map
  extend ActiveSupport::Concern

  included do
    has_many :maps, class_name: 'Cms::Map', dependent: :destroy, as: :map_attachable
    accepts_nested_attributes_for :maps
    before_validation :prepare_maps, if: -> { @save_maps }
  end

  def maps_attributes=(val)
    @save_maps = true
    super
  end

  def default_map_position
    map_coordinate = Cms::SiteSetting.find_by(name: 'map_coordinate').try(:value)
    return Zomeki.config.application["cms.default_map_coordinate"] unless map_coordinate != ""
    map_coordinate
  end

  private

  def prepare_maps
    maps.each do |map|
      map.markers.each do |marker|
        if marker.name.blank? && marker.lat.blank? && marker.lng.blank?
          marker.mark_for_destruction
        end
      end
    end
  end
end
