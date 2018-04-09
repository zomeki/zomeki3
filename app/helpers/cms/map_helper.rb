module Cms::MapHelper
  def default_map_position(content)
    [content.map_coordinate,
     content.site.map_coordinate,
     Zomeki.config.application["cms.default_map_coordinate"]].lazy.each do |coord|
      p = coord.to_s.split(',').map(&:strip)
      return p if p.size == 2
    end
    return nil
  end
end
