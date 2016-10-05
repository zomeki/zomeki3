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
    '35.702708,139.560831' # Mitaka
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
