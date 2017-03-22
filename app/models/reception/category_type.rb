class Reception::CategoryType < GpCategory::CategoryType
  def bread_crumbs(node)
    crumbs = []

    if node.content
      c = node.bread_crumbs.crumbs.first
      c << [title, "#{node.public_uri}categories/#{name}/"]
      crumbs << c
    end

    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
