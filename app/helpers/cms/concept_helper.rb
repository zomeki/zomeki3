module Cms::ConceptHelper
  def concept_tree(concepts, parent = nil)
    cont_paths = params[:controller].split('/')
    full_paths = request.fullpath.split('/')

    concepts.map do |concept|
      icon_cls = ["icon"]
      icon_cls << "opened" if concept.children.size > 0
      icon_mark = concept.children.size > 0 ? "-" : " "
      item_cls = ["item"]
      item_cls << "current" if Core.concept && Core.concept.id == concept.id

      content_tag :li do
        html = ''
        html << link_to(icon_mark, "#", class: icon_cls.join(' '))
        html << " "

        url = if cont_paths[0].in?(%w(sys cms)) || cont_paths[2].in?(%w(piece node))
                { action: :index, concept: concept.id }
              elsif full_paths[2].in?(%w(plugins))
                "#{full_paths[0..3].compact.join('/')}?concept=#{concept.id}"
              else
                main_app.cms_contents_path(concept: concept.id)
              end
        html << link_to(concept.name, url, class: item_cls.join(' '))

        if concept.children.size > 0
          html << content_tag(:ul) { concept_tree(concept.children, parent: concept) }
        end

        html.html_safe
      end
    end.join.html_safe
  end
end
