class Cms::Public::InquiryFormatService < FormatService
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def format(inquiry_style, mobile: false)
    contents = {
      name: -> { replace_name },
      address: -> { replace_address },
      tel: -> { replace_tel },
      fax: -> { replace_fax },
      email: -> { replace_email },
      email_link: -> { replace_email_link },
      note: -> { replace_note },
    }

    inquiry_style = inquiry_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
    inquiry_style.html_safe
  end

  private

  def replace_name
    if (group = @inquiry.group) && group.name.present?
      content_tag :div, group.name, class: 'section'
    end
  end

  def replace_address
    if @inquiry.address.present?
      content_tag :div, class: 'address' do
        concat content_tag :span, '住所', class: 'label'
        concat "：#{@inquiry.address}"
      end
    end
  end

  def replace_tel
    if @inquiry.tel.present?
      content_tag :div, class: 'tel' do
        concat content_tag :span, 'TEL', class: 'label'
        concat "：#{@inquiry.tel}#{@inquiry.tel_attend}"
      end
    end
  end

  def replace_fax
    if @inquiry.fax.present?
      content_tag :div, @inquiry.fax, class: 'fax' do
        concat content_tag :span, 'FAX', class: 'label'
        concat "：#{@inquiry.fax}"
      end
    end
  end

  def replace_email
    if @inquiry.email.present?
      content_tag :div, class: 'email' do
        concat content_tag :span, 'E-Mail', class: 'label'
        concat "：#{@inquiry.email}"
      end
    end
  end

  def replace_email_link
    if @inquiry.email.present?
      content_tag :div, class: 'email' do
        concat content_tag :span, 'E-Mail', class: 'label'
        concat '：'
        concat mail_to @inquiry.email
      end
    end
  end

  def replace_note
    if @inquiry.note.present?
      content_tag :div, class: 'note' do
        concat content_tag :span, '備考', class: 'label'
        concat "：#{@inquiry.note}"
      end
    end
  end
end
