module TagHelper
  def content_wrapper_tag(tag, options = {})
    if tag == 'li'
      content_tag :ul, options do
        yield
      end
    else
      yield
      ''
    end
  end

  def content_tag_if(condition, tag, options = {})
    if condition
      content_tag tag, options do
        yield
      end
    else
      yield
    end
  end
end
