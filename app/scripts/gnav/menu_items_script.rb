class Gnav::MenuItemsScript < PublicationScript
  def publish
    publish_more(@node, uri: @node.public_uri,
                        path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path)

    @node.content.public_menu_items.each do |menu_item|
      publish_more(menu_item, uri: menu_item.public_uri,
                              path: menu_item.public_path,
                              smart_phone_path: menu_item.public_smart_phone_path)
    end
  end
end
