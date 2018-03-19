module Cms::ConceptHelper
  def concept_tree(concepts = nil)
    concepts ||= Core.site.concepts.readable_for(Core.user).to_tree

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

        url = if request.fullpath.split('/')[2].in?(%w(sys cms))
                { action: :index, concept: concept.id }
              else
                cms_contents_path(concept.id)
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
