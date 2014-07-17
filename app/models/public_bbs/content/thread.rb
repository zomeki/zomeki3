# encoding: utf-8
class PublicBbs::Content::Thread < Cms::Content
  def category_node
    return @category_node if @category_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PublicBbs::Category'
    @category_node = item.find(:first, :order => :id)
  end

  def recent_thread_node
    return @recent_thread_node if @recent_thread_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PublicBbs::RecentThread'
    @recent_thread_node = item.find(:first, :order => :id)
  end

  def tag_node
    return @tag_node if @tag_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'PublicBbs::TagThread'
    @tag_node = item.find(:first, :order => :id)
  end

  def thread_node
    return @thread_node if @thread_node
    @thread_node = Cms::Node.public.where(content_id: id)
                                   .where(model: 'PublicBbs::Thread')
                                   .order(:id).first
  end

  def portal_group
    PortalGroup::Content::Group.find_by_id(setting_value(:portal_group_id))
  end
end
