class Cms::Lib::BreadCrumbs
  include ActionView::Helpers

  @crumbs = []

  def initialize(crumbs = [])
    @crumbs = crumbs if crumbs
  end

  def crumbs
    @crumbs
  end

  def to_links(options = {})
    top_label = if options[:top_label].present?
                  options[:top_label]
                else
                  'TOP'
                end

    h = ''
    @crumbs.each do |r|
      links = ''
      if r.first[1] == Page.site.uri
        r.first[0] = top_label
      end
      if r.last[1] =~ /index\.html$/
        r.pop
      end
      r.each do |c|
        if c[0].class == Array
          l = []
          c.each do |c2|
            links << content_tag(:li, link_to(c2[0], c2[1].to_s))
          end
        else
          links << content_tag(:li, link_to(c[0], c[1].to_s))
        end
      end
      h << content_tag(:ol, links.html_safe)
    end
    h.html_safe
  end
end
