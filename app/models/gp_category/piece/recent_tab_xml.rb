class GpCategory::Piece::RecentTabXml < Cms::Model::Base::PieceExtension
  CONDITION_OPTIONS = [['すべてを含む', 'and'], ['いずれかを含む', 'or']]
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]

  set_model_name 'gp_category/piece/recent_tab'
  set_column_name :xml_properties
  set_node_xpath 'tabs/tab'
  set_primary_key :name

  attr_accessor :name
  attr_accessor :title
  attr_accessor :more
  attr_accessor :condition
  attr_accessor :sort_no

  # 内部実装の制約上配列内に同じ値を複数保存出来ないため、工夫が必要。
  elem_accessor :elem_category_ids
  elem_accessor :elem_layers

  validates_presence_of :name, :title, :sort_no

  def condition_name
    CONDITION_OPTIONS.detect{|o| o.last == condition }.try(:first).to_s
  end

  def categories_with_layer
    categories_with_layer_array = load_categories_with_layer_array
    categories_with_layer_array.sort do |a, b|
      next a[:category].category_type.sort_no <=> b[:category].category_type.sort_no unless a[:category].category_type.sort_no == b[:category].category_type.sort_no
      next a[:category].category_type.id      <=> b[:category].category_type.id      unless a[:category].category_type.id      == b[:category].category_type.id
      next a[:category].level_no              <=> b[:category].level_no              unless a[:category].level_no              == b[:category].level_no
      next a[:category].parent_id             <=> b[:category].parent_id             unless a[:category].parent_id             == b[:category].parent_id
      next a[:category].sort_no               <=> b[:category].sort_no               unless a[:category].sort_no               == b[:category].sort_no
           a[:category].id                    <=> b[:category].id
    end
  end

  def public_doc_ids
    doc_ids = categories_with_layer.map do |category_with_layer|
      if category_with_layer[:layer] == 'descendants'
        category_with_layer[:category].descendants.inject([]) {|result, item| result | item.doc_ids }
      else
        category_with_layer[:category].doc_ids
      end
    end

    case condition
    when 'and'
      doc_ids.inject(doc_ids.shift) {|result, item| result & item }
    when 'or'
      doc_ids.inject([]) {|result, item| result | item }
    else
      []
    end
  end

  def more_dir
    return if more.blank?
    more.end_with?('/') ? more : "#{File.dirname(more)}/"
  end

  private

  def load_categories_with_layer_array
    return [] if elem_category_ids.blank? || elem_layers.blank?

    array = []
    elem_category_ids.each_with_index do |category_id, index|
      if (category = GpCategory::Category.find_by(id: category_id))
        array << {
          category: category,
          layer: elem_layers[index].sub(Regexp.new("^#{index}_"), '')
        }
      end
    end
    array
  end
end
