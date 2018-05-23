module Cms::ConceptHelper
  def concept_tree(concepts = nil)
    concepts ||= Core.site.concepts.readable_for(Core.user).to_tree

    cont_paths = params[:controller].split('/')
    full_paths = request.fullpath.split('/')

    concepts.map do |concept|
      children = concept.children

      icon_cls = ["icon"]
      icon_cls << (children.size > 0) ? "openedChildren" : "noChildren"
      icon_mark = (children.size > 0) ? "-" : " "
      item_cls = ["item"]
      item_cls << "current" if Core.concept && Core.concept.id == concept.id

      content_tag :li do
        html = ''
        html << link_to(icon_mark, "#", id: "naviConceptIcon#{concept.id}", class: icon_cls.join(' '))
        html << " "

        url = if cont_paths[0].in?(%w(sys cms)) || cont_paths[2].in?(%w(piece node))
                { action: :index, concept: concept.id }
              elsif full_paths[2].in?(%w(plugins))
                "#{full_paths[0..3].compact.join('/')}?concept=#{concept.id}"
              else
                main_app.cms_contents_path(concept: concept.id)
              end
        html << link_to(concept.name, url, id: "naviConceptItem#{concept.id}", class: item_cls.join(' '))

        if children.size > 0
          html << content_tag(:ul, id: "naviConceptList#{concept.id}") do
            concept_tree(children)
          end
        end

        html.html_safe
      end
    end.join.html_safe
  end
end
