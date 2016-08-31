module Cms::Model::Rel::Map
  extend ActiveSupport::Concern

  included do
    has_many :maps, class_name: 'Cms::Map', dependent: :destroy, as: :map_attachable
    after_save :save_maps
  end

  # setter always returns supplied argument
  def in_maps=(val)
    @maps_attributes = val
  end

  def in_maps
    return @maps_attributes if defined? @maps_attributes

    maps_attrs = {}.with_indifferent_access
    maps.each_with_index do |map, i|
      maps_attrs[i.to_s] = {
        name: map.name,
        title: map.title,
        map_lat: map.map_lat,
        map_lng: map.map_lng,
        map_zoom: map.map_zoom
      }
      markers_attrs = {}.with_indifferent_access
      map.markers.each_with_index do |marker, j|
        markers_attrs[j.to_s] = {
          name: marker.name,
          lat: marker.lat,
          lng: marker.lng
        }
      end
      maps_attrs[i.to_s][:markers] = markers_attrs
    end
    @maps_attributes = maps_attrs
  end

  def default_map_position
    '35.702708,139.560831' # Mitaka
  end

  private

  def save_maps
    return false unless @maps_attributes.kind_of?(Hash)

    ma = @maps_attributes
    @maps_attributes = nil

    ma.values.each do |map_attrs|
      name = map_attrs[:name] || '1'
      map = maps.find_or_initialize_by(name: name)
      map.title = map_attrs[:title]
      map.map_lat = map_attrs[:map_lat]
      map.map_lng = map_attrs[:map_lng]
      map.map_zoom = map_attrs[:map_zoom]
      next unless map.save

      if (markers_attrs = map_attrs[:markers]).kind_of?(Hash)
        attrs = markers_attrs.values.delete_if {|a| a.values.all?(&:blank?) }
        markers = map.markers
        (attrs.size > markers.size ? attrs.size : markers.size).times do |n|
          attr = attrs[n]
          marker = markers[n]
          if attr
            attr[:sort_no] = n
            if marker
              marker.update_attributes(attr)
            else
              markers.create(attr)
            end
          else
            marker.destroy
          end
        end
      end
    end

    return true
  end
end
