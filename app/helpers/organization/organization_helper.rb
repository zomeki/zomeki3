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
    contents = {
      name: -> { group_replace_name(group) },
      name_link: -> { group_replace_name_link(group) },
      address: -> { group_replace_address(group) },
      tel: -> { group_replace_tel(group) },
      tel_attend: -> { group_replace_tel_attend(group) },
      fax: -> { group_replace_fax(group) },
      email: -> { group_replace_email(group) },
      email_link: -> { group_replace_email_link(group) },
      note: -> { group_replace_note(group) },
    }

    if Page.mobile?
      contents[:name_link].call
    else
      list_style = list_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
      list_style.html_safe
    end
  end

  private

  def group_replace_name(group)
    if (sg = group.sys_group) && sg.name.present?
      content_tag :span, sg.name, class: 'name'
    else
      ''
    end
  end

  def group_replace_name_link(group)
    if (sg = group.sys_group) && sg.name.present?
      content_tag :span, class: 'name' do
        link_to sg.name, group.public_uri
      end
    else
      ''
    end
  end

  def group_replace_address(group)
    if (sg = group.sys_group) && sg.address.present?
      content_tag :span, sg.address, class: 'address'
    else
      ''
    end
  end

  def group_replace_tel(group)
    if (sg = group.sys_group) && sg.tel.present?
      content_tag :span, sg.tel, class: 'tel'
    else
      ''
    end
  end

  def group_replace_tel_attend(group)
    if (sg = group.sys_group) && sg.tel_attend.present?
      content_tag :span, sg.tel_attend, class: 'tel_attend'
    else
      ''
    end
  end

  def group_replace_fax(group)
    if (sg = group.sys_group) && sg.fax.present?
      content_tag :span, sg.fax, class: 'fax'
    else
      ''
    end
  end

  def group_replace_email(group)
    if (sg = group.sys_group) && sg.email.present?
      content_tag :span, sg.email, class: 'email'
    else
      ''
    end
  end

  def group_replace_email_link(group)
    if (sg = group.sys_group) && sg.email.present?
      content_tag :span, class: 'email' do
        mail_to sg.email
      end
    else
      ''
    end
  end

  def group_replace_note(group)
    if (sg = group.sys_group) && sg.note.present?
      content_tag :span, sg.note, class: 'note'
    else
      ''
    end
  end
end
