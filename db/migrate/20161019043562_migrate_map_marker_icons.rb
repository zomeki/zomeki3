class MigrateMapMarkerIcons < ActiveRecord::Migration[5.0]
  def up
    %w(GpCategory::CategoryType GpCategory::Category).each do |type|
      items = Cms::ContentSetting.where("name like '#{type}%'")
      items.each do |item|
        if (id = item.name.scan(/#{type} (\d+) icon_image/)[0].try(:first))
          Map::MarkerIcon.create(
            content_id: item.content_id,
            relatable_type: type,
            relatable_id: id,
            url: item.value
          )
          item.destroy
        end
      end
    end
  end

  def down
  end
end
