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
end
