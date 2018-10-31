class GpArticle::DocCsvService < ApplicationService
  def initialize(content, docs, criteria)
    @content = content
    @docs = docs
    @criteria = criteria

    @category_types = @content.visible_category_types
    @event_category_types = @content.event_category_types
    @marker_category_types = @content.marker_category_types
  end

  def generate
    require 'csv'
    CSV.generate(force_quotes: true) do |csv|
      csv << [criteria_header]
      csv << doc_header

      @docs.each do |doc|
        csv << doc_to_csv(doc)
      end
    end
  end

  private

  def criteria_header
    headers = []
    headers << "所属:#{@criteria.target_text}" if @criteria.target_text.present?
    headers << "公開:#{@criteria.target_state_text_for_csv}" if @criteria.target_state_text_for_csv.present?
    headers << "記事番号:#{@criteria.serial_no}" if @criteria.serial_no.present?
    headers << "キーワード:#{@criteria.free_word}" if @criteria.free_word.present?
    headers << "カテゴリ:#{@criteria.category_texts.join(' ')}" if @criteria.category_texts.present?
    headers << "日付:#{@criteria.date_options_text}" if @criteria.date_options_text.present?
    headers << "状態:#{@criteria.state_text}" if @criteria.state_text.present?
    headers << "ユーザー:#{@criteria.user_options_text}" if @criteria.user_options_text.present?
    headers << @criteria.check_box_options_text if @criteria.check_box_options_text.present?
    headers.join(' ')
  end

  def doc_header
    # 基本情報
    data = ['_ID', '記事番号', '状態', '公開URL', 'タイトル', '記事一覧表示',
            'ディレクトリ名', '所属', '作成者', '作成日時', '更新日時']
    data += @category_types.map(&:title)

    # 公開日
    data += ['公開日（表示用）', '更新日（表示用）', '公開開始日時', '公開終了日時']

    # 連絡先
    data += ['連絡先表示', '連絡先']

    # イベント
    data += ['イベントカレンダー表示', 'イベント期間', 'イベント備考']
    data += @event_category_types.map(&:title)

    # 地図
    data += ['マップ表示', 'ルート案内', 'マップ並び順', 'マップ名', '座標', '縮尺', 'マーカー']
    data += @marker_category_types.map(&:title)

    # 携帯
    data += ['携帯タイトル']

    data
  end

  def doc_to_csv(doc)
    data = []

    # 基本情報
    data << doc.id
    data << doc.serial_no
    data << doc.state_text
    data << doc.public_uri
    data << doc.title
    data << doc.feature_1_text
    data << doc.name
    data << doc.creator&.group&.name
    data << doc.creator&.user&.name
    data << localize_datetime(doc.created_at)
    data << localize_datetime(doc.updated_at)

    @category_types.each do |category_type|
      data << doc.categories.select { |cat| cat.category_type == category_type }.map(&:title).join("\n")
    end

    # 公開日
    data << localize_datetime(doc.display_published_at)
    data << localize_datetime(doc.display_updated_at)

    publish_task = doc.tasks.detect(&:publish_task?)
    close_task = doc.tasks.detect(&:close_task?)
    data << localize_datetime(publish_task&.process_at)
    data << localize_datetime(close_task&.process_at)

    # 連絡先
    data << (doc.inquiries.first.present? ? doc.inquiries.first.state_text : nil)
    data << doc.inquiries.map { |inquiry| inquiry.group&.name }.join("\n")

    # イベント
    data << doc.event_state_text
    data << doc.periods.map { |p| "#{localize_datetime(p.started_on)} ～ #{p.ended_on}" }.join("\n")
    data << doc.event_note

    @event_category_types.each do |category_type|
      data << doc.event_categories.select { |cat| cat.category_type == category_type }.map(&:title).join("\n")
    end

    # 地図
    data << doc.marker_state_text
    data << doc.navigation_state_text
    data << doc.marker_sort_no

    map = doc.maps.first
    data << (map ? map.title : nil)
    data << (map && (map.map_lat.present? || map.map_lng.present?) ? "#{map.map_lat},#{map.map_lng}" : nil)
    data << (map ? map.map_zoom : nil)
    data << (map ? map.markers.map { |marker| "#{marker.name} (#{marker.lat},#{marker.lng})" }.join("\n") : nil)


    @marker_category_types.each do |category_type|
      data << doc.marker_categories.select { |cat| cat.category_type == category_type }.map(&:title).join("\n")
    end

    # 携帯
    data << doc.mobile_title

    data
  end

  def localize_datetime(value)
    I18n.l(value) if value
  end
end
