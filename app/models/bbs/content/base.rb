# encoding: utf-8
class Bbs::Content::Base < Cms::Content
  def thread_node
    return @thread_node if @thread_node
    @thread_node = Cms::Node.public.where(content_id: id)
                                   .where(model: 'Bbs::Thread')
                                   .order(:id).first
  end
end
