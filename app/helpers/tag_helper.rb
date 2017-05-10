module TagHelper
  def content_wrapper_tag(tag, options = {})
    if tag == 'li'
      content_tag :ul, options[:ul] do
        content_tag :li, options[:li] do
          yield
        end
      end
    else
      content_tag tag, options do
        yield
      end
    end
  end
end
