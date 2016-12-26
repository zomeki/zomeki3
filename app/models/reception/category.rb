class Reception::Category < GpCategory::Category
  def bread_crumbs(node)
    crumbs = []

    if node.content
      c = node.bread_crumbs.crumbs.first
      ancestors.each {|a| c << [a.title, "#{node.public_uri}categories/#{category_type.name}/#{a.path_from_root_category}/"] }
      crumbs << c
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
