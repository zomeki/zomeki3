module Organization::GroupHelper
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
    Formatter.new(group).format(list_style, mobile: request.mobile?)
  end

  class Formatter < ActionView::Base
    include ::ApplicationHelper
    include ::DateHelper

    def initialize(group)
      @group = group
      @sys_group = @group.sys_group
    end

    def format(list_style, mobile: false)
      contents = {
        name: -> { replace_name },
        name_link: -> { replace_name_link },
        address: -> { replace_address },
        tel: -> { replace_tel },
        tel_attend: -> { replace_tel_attend },
        fax: -> { replace_fax },
        email: -> { replace_email },
        email_link: -> { replace_email_link },
        note: -> { replace_note },
      }

      if mobile
        contents[:name_link].call
      else
        list_style = list_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
        list_style.html_safe
      end
    end

    private

    def replace_name
      if @sys_group && @sys_group.name.present?
        content_tag :span, @sys_group.name, class: 'name'
      end
    end

    def replace_name_link
      if @sys_group && @sys_group.name.present?
        content_tag :span, class: 'name' do
          link_to @sys_group.name, @group.public_uri
        end
      end
    end

    def replace_address
      if @sys_group && @sys_group.address.present?
        content_tag :span, @sys_group.address, class: 'address'
      end
    end

    def replace_tel
      if @sys_group && @sys_group.tel.present?
        content_tag :span, @sys_group.tel, class: 'tel'
      end
    end

    def replace_tel_attend
      if @sys_group && @sys_group.tel_attend.present?
        content_tag :span, @sys_group.tel_attend, class: 'tel_attend'
      end
    end

    def replace_fax
      if @sys_group && @sys_group.fax.present?
        content_tag :span, @sys_group.fax, class: 'fax'
      end
    end

    def replace_email
      if @sys_group && @sys_group.email.present?
        content_tag :span, @sys_group.email, class: 'email'
      end
    end

    def replace_email_link
      if @sys_group && @sys_group.email.present?
        content_tag :span, class: 'email' do
          mail_to @sys_group.email
        end
      end
    end

    def replace_note
      if @sys_group && @sys_group.note.present?
        content_tag :span, @sys_group.note.html_safe, class: 'note'
      end
    end
  end
end
