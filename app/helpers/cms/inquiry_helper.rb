module Cms::InquiryHelper
  def inquiry_replace(inquiry, inquiry_style)
    contents = {
      name: -> { inquiry_replace_name(inquiry) },
      address: -> { inquiry_replace_address(inquiry) },
      tel: -> { inquiry_replace_tel(inquiry) },
      fax: -> { inquiry_replace_fax(inquiry) },
      email: -> { inquiry_replace_email(inquiry) },
      email_link: -> { inquiry_replace_email_link(inquiry) },
      note: -> { inquiry_replace_note(inquiry) },
    }

    inquiry_style = inquiry_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
    inquiry_style.html_safe
  end

  private

  def inquiry_replace_name(inquiry)
    if (group = inquiry.group) && group.name.present?
      content_tag :div, group.name, class: 'section'
    else
      ''
    end
  end

  def inquiry_replace_address(inquiry)
    if inquiry.address.present?
      content_tag :div, class: 'address' do
        concat content_tag :span, '住所', class: 'label'
        concat "：#{inquiry.address}"
      end
    else
      ''
    end
  end

  def inquiry_replace_tel(inquiry)
    if inquiry.tel.present?
      content_tag :div, class: 'tel' do
        concat content_tag :span, 'TEL', class: 'label'
        concat "：#{inquiry.tel}#{inquiry.tel_attend}"
      end
    else
      ''
    end
  end

  def inquiry_replace_fax(inquiry)
    if inquiry.fax.present?
      content_tag :div, inquiry.fax, class: 'fax' do
        concat content_tag :span, 'FAX', class: 'label'
        concat "：#{inquiry.fax}"
      end
    else
      ''
    end
  end

  def inquiry_replace_email(inquiry)
    if inquiry.email.present?
      content_tag :div, class: 'email' do
        concat content_tag :span, 'E-Mail', class: 'label'
        concat "：#{inquiry.email}"
      end
    else
      ''
    end
  end

  def inquiry_replace_email_link(inquiry)
    if inquiry.email.present?
      content_tag :div, class: 'email' do
        concat content_tag :span, 'E-Mail', class: 'label'
        concat '：'
        concat mail_to inquiry.email
      end
    else
      ''
    end
  end

  def inquiry_replace_note(inquiry)
    if inquiry.note.present?
      content_tag :div, class: 'note' do
        concat content_tag :span, '備考', class: 'label'
        concat "：#{inquiry.note}"
      end
    else
      ''
    end
  end
end
