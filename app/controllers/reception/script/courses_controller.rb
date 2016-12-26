class Reception::Script::CoursesController < Cms::Controller::Script::Publication
  def publish
    uri  = "#{@node.public_uri}"
    path = "#{@node.public_path}"
    smart_phone_path = "#{@node.public_smart_phone_path}"

    publish_page(@node, uri: uri, path: path)
    publish_page(@node, uri: uri, path: smart_phone_path, dependent: 'smart_phone')

    if @node.content.doc_list_style == 'all_categories'
      category_types = @node.content.visible_category_types
      category_types.each do |category_type|
        category_type.public_root_categories.each do |category|
          publish_category(category)
        end
      end
    end
    render plain: 'OK'
  end

  def publish
    render plain: 'OK'
  end

  private

  def publish_category(cat)
    cat_path = "#{cat.category_type.name}/#{cat.path_from_root_category}/"
    uri = "#{@node.public_uri}categories/#{cat_path}"
    path = "#{@node.public_path}categories/#{cat_path}"
    smart_phone_path = "#{@node.public_smart_phone_path}#{cat_path}"

    publish_page(@node, uri: uri, path: path, dependent: cat_path)
    publish_page(@node, uri: uri, path: smart_phone_path, dependent: "#{cat_path}smart_phone", smart_phone: true)

    cat.public_children.each do |c|
      publish_category(c)
    end
  end
end
