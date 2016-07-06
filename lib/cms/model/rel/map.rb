module Cms::Model::Rel::Map
  def self.included(mod)
    mod.has_many :maps, class_name: 'Cms::Map', dependent: :destroy, as: :map_attachable
    mod.after_save :save_maps
  end

  # setter always returns supplied argument
  def in_maps=(values)
    @maps_attributes = (case values
                        when Array
                          values
                        when Hash
                          values.values
                        else
                          []
                        end)
  end

  def in_maps
    @maps_attributes ||= maps.map {|m| m.in_attributes }
  end

  def default_map_position
    '35.702708,139.560831' # Mitaka
  end

  def find_map_by_name(name)
    maps.find_by(name: name)
  end

  private

  def save_maps
    return false unless @maps_attributes.kind_of?(Array)

    ma = @maps_attributes
    @maps_attributes = nil

    ma.each do |map_attributes|
      name = map_attributes[:name] || '1'
      map = maps.find_or_initialize_by(name: name)
      map.title = map_attributes[:title]
      map.map_lat = map_attributes[:map_lat]
      map.map_lng = map_attributes[:map_lng]
      map.map_zoom = map_attributes[:map_zoom]
      next unless map.save

      if (markers_attributes = map_attributes[:markers]).kind_of?(Hash)
        attrs = markers_attributes.values.delete_if {|a| a.values.all?(&:blank?) }
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
            marker.destroy if map.new_marker_format?
          end
        end
      end

      map.convert_to_new_marker_format
    end

    return true
  end
end
