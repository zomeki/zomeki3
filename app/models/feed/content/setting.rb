class Feed::Content::Setting < Cms::ContentSetting
  set_config :list_style,
    name: "記事表示形式",
    form_type: :text_area,
    upper_text: '<a href="#" class="show_dialog">置き換えテキストを確認する</a>',
    default_value: '@title_link@(@publish_date@)'
  set_config :new_term,
    name: "新着マーク表示期間",
    comment: "時間（1日=24時間）、0:非表示"

  belongs_to :content, foreign_key: :content_id, class_name: 'Feed::Content::Feed'

  validate :validate_value

  private

  def validate_value
    case name
    when 'new_term'
      if !value.blank? && value !~ /^([1-9]\d*|0)(\.\d+)?$/
        errors.add :value, :invalid
      end
    end
  end
end
