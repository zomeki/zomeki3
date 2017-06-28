class GpCategory::CategoryTypesScript < PublicationScript
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path)

    category_types = @node.content.public_category_types
    category_types.where!(id: params[:target_category_type_id]) if params[:target_category_type_id].present?
    category_types.each do |category_type|
      uri = "#{@node.public_uri}#{category_type.name}/"
      path = "#{@node.public_path}#{category_type.name}/"
      smart_phone_path = "#{@node.public_smart_phone_path}#{category_type.name}/"

      publish_page(category_type, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
      publish_page(category_type, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)
      publish_more(category_type, uri: uri, path: path, smart_phone_path: smart_phone_path)
      publish_more(category_type, uri: uri, path: path, smart_phone_path: smart_phone_path, file: 'more', dependent: :more)

      publish_category_type_for_template_modules(category_type)

      categories = category_type.public_categories.reorder(:level_no, :sort_no)
      categories.where!(id: params[:target_category_id]) if params[:target_category_id].present?
      categories.each do |category|
        publish_category(category)
      end
    end
  end

  private

  def category_feed_pieces(item)
    layout = item.layout || @node.layout
    return nil unless layout

    feed_piece_ids = layout.pieces.select{|piece| piece.model == 'GpCategory::Feed'}.map(&:id)
    GpCategory::Piece::Feed.where(:id => feed_piece_ids).all
  end

  def publish_category(cat)
    cat_path = "#{cat.category_type.name}/#{cat.path_from_root_category}/"
    uri = "#{@node.public_uri}#{cat_path}"
    path = "#{@node.public_path}#{cat_path}"
    smart_phone_path = "#{@node.public_smart_phone_path}#{cat_path}"

    publish_page(cat, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(cat, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)

    if @node.content.category_style == 'categories_with_docs'
      publish_page(cat, uri: uri, path: path, smart_phone_path: smart_phone_path)
    else
      publish_more(cat, uri: uri, path: path, smart_phone_path: smart_phone_path)
    end

    publish_more(cat, uri: uri, path: path, smart_phone_path: smart_phone_path, file: 'more', dependent: :more)

    if feed_pieces = category_feed_pieces(cat)
      feed_pieces.each do |piece|
        rss = piece.public_feed_uri('rss')
        atom = piece.public_feed_uri('atom')
        publish_page(cat, uri: "#{uri}#{rss}", path: "#{path}#{rss}", dependent: rss)
        publish_page(cat, uri: "#{uri}#{atom}", path: "#{path}#{atom}", dependent: atom)
      end
    end

    publish_category_for_template_modules(cat)

    info_log %Q!OK: Published to "#{path}"!
  end

  def publish_category_type_for_template_modules(cat_type)
    t = cat_type.template
    return unless t

    tms = t.containing_modules
    tms.each do |tm|
      case tm.module_type
      when 'docs_1', 'docs_2'
        publish_link(cat_type, ApplicationController.helpers.category_module_more_link(template_module: tm, ct_or_c: cat_type))
      when 'docs_3', 'docs_4'
        next unless cat_type.internal_category_type
        cat_type.internal_category_type.public_root_categories.each do |c|
          publish_link(cat_type, ApplicationController.helpers.category_module_more_link(template_module: tm, ct_or_c: cat_type, category_name: c.name))
        end
      when 'docs_5', 'docs_6'
        docs = GpCategory::CategoryType.public_docs_for_template_module(cat_type, tm)
                                       .select(Sys::Group.arel_table[:id]).distinct
                                       .joins(creator: :group)
        groups = Sys::Group.where(id: docs)
        groups.each do |group|
          publish_link(cat_type, ApplicationController.helpers.category_module_more_link(template_module: tm, ct_or_c: cat_type, group_code: group.code))
        end
      end
    end
  end

  def publish_category_for_template_modules(cat)
    t = cat.inherited_template
    return unless t

    tms = t.containing_modules
    tms.each do |tm|
      case tm.module_type
      when 'docs_1', 'docs_2'
        publish_link(cat, ApplicationController.helpers.category_module_more_link(template_module: tm, ct_or_c: cat))
      when 'docs_3', 'docs_4'
        next unless cat.category_type.internal_category_type
        cat.category_type.internal_category_type.public_root_categories.each do |c|
          publish_link(cat, ApplicationController.helpers.category_module_more_link(template_module: tm, ct_or_c: cat, category_name: c.name))
        end
      when 'docs_5', 'docs_6'
        docs = GpCategory::Category.public_docs_for_template_module(cat, tm)
                                   .select(Sys::Group.arel_table[:id]).distinct
                                   .joins(creator: :group)
        groups = Sys::Group.where(id: docs)
        groups.each do |group|
          publish_link(cat, ApplicationController.helpers.category_module_more_link(template_module: tm, ct_or_c: cat, group_code: group.code))
        end
      end
    end
  end

  def publish_link(cat, link)
    public_path = cat.content.site.public_path

    uri = "#{File.dirname(link)}/"
    path = "#{public_path}#{uri}"
    smart_phone_path = "#{public_path}/_smartphone#{uri}"
    file = File.basename(link, '.html')

    publish_more(cat, uri: uri, path: path, smart_phone_path: smart_phone_path, file: file, dependent: file)
  end
end
