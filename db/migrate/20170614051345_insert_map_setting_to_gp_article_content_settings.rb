class InsertMapSettingToGpArticleContentSettings < ActiveRecord::Migration[5.0]
  def up
    content_ids = Cms::Content.where(model: 'GpArticle::Doc').pluck(:id)
    Cms::ContentSetting.where(content_id: content_ids, name: 'map_relation').each do |setting|
     Cms::ContentSetting.create(
        content_id: setting.content_id,
        name: 'map_setting',
        value: setting.value,
        extra_value: YAML.dump(HashWithIndifferentAccess.new(lat_lng: YAML.load(setting.extra_value.presence || '{}')['lat_lng'].to_s))
      )
    end
  end
  def down
  end
end
