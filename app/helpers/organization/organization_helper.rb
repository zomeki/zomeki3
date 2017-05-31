module Organization::OrganizationHelper
  def group_li(group, list_style, depth_limit: 1000, depth: 1)
    content_tag(:li) do
      result = group_replace(group, list_style)
      if group.public_children.empty? || depth >= depth_limit
        result
      else
        result << content_tag(:ul) do
            group.public_children.inject(''){|lis, child|
              lis << group_li(child, list_style, depth_limit: depth_limit, depth: depth + 1)
            }.html_safe
          end
      end
    end
  end

  def group_replace(group, list_style)
    Organization::Public::GroupFormatService.new(group).format(list_style, mobile: Page.mobile?)
  end
end
