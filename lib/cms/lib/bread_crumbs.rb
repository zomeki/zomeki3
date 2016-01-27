# encoding: utf-8
class Cms::Lib::BreadCrumbs
  @crumbs = []
  def initialize(crumbs = [])
    @crumbs = crumbs if crumbs
  end

  def crumbs
    @crumbs
  end

  def to_links(options = {})

    vc = ApplicationController.view_context_class.new
    top_label = 'TOP'
    top_label = options[:top_label] if !options[:top_label].blank?
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
            links << vc.content_tag(:li, vc.link_to(c2[0], c2[1]))
          end
        else
          links << vc.content_tag(:li, vc.link_to(c[0], c[1]))
        end
      end
      h << vc.content_tag(:ol, links.html_safe)
    end
    h.html_safe
  end
end
