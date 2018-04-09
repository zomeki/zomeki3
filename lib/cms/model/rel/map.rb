module Cms::Model::Rel::Map
  extend ActiveSupport::Concern

  included do
    has_many :maps, class_name: 'Cms::Map', dependent: :destroy, as: :map_attachable
    accepts_nested_attributes_for :maps
    before_validation :prepare_maps, if: -> { @maps_attributes_changed }
  end

  def maps_attributes=(val)
    @maps_attributes_changed = true
    super
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
