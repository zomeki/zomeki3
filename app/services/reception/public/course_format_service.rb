class Reception::Public::CourseFormatService < FormatService
  def initialize(course)
    @course = course
  end

  def format(course_style, datetime_style = '', mobile: false)
    contents = {
      title: -> { replace_title },
      subtitle: -> { replace_subtitle },
      summary: -> { replace_summary },
      total_number: -> { replace_total_number },
      charge: -> { replace_charge },
      remarks: -> { replace_remarks },
      hold_date: -> { replace_hold_date(datetime_style) },
      place: -> { replace_place },
      name: -> { replace_name },
      link: -> { replace_link },
      category: -> { replace_category },
    }

    if mobile
      contents[:link].call
    else
      course_style = course_style.gsub(/@(\w+)@/) { |m| contents[$1.to_sym].try(:call).to_s }
      course_style.html_safe
    end
  end

  private

  def replace_title
    if @course.title.present?
      content_tag(:span, @course.title, class: 'title')
    end
  end

  def replace_subtitle
    if @course.subtitle.present?
      content_tag(:span, @course.subtitle, class: 'subtitle')
    end
  end

  def replace_summary
    if @course.body.present?
      content_tag(:span, @course.body.html_safe, class: 'summary')
    end
  end

  def replace_total_number
    if @course.capacity.present?
      content_tag(:span, @course.capacity, class: 'total_number')
    end
  end

  def replace_charge
    if @course.fee.present?
      content_tag(:span, @course.fee, class: 'charge')
    end
  end

  def replace_remarks
    if @course.remark.present?
      content_tag(:span, @course.remark.html_safe, class: 'remarks')
    end
  end

  def replace_hold_date(datetime_style)
    open = @course.public_opens.select(&:applicable?).first || @course.public_opens.last
    if open && open.open_on
      ds = localize_wday(datetime_style, open.open_on.wday)
      content_tag(:span, open.open_on_start_at.strftime(ds), class: 'hold_date')
    end
  end

  def replace_place
    open = @course.public_opens.select(&:applicable?).first
    if open && open.place.present?
      content_tag(:span, open.place, class: 'place')
    end
  end

  def replace_name
    open = @course.public_opens.select(&:applicable?).first
    if open && open.lecturer.present?
      content_tag(:span, open.lecturer, class: 'name')
    end
  end

  def replace_link
    link = link_to(@course.title, @course.public_uri)
    if link.present?
      content_tag(:span, link, class: 'link')
    end
  end

  def replace_category
    categories = @course.categories
    if categories.present?
      category_text = categories.map { |c|
        content_tag(:span, c.title, class: "#{c.category_type.name}-#{c.ancestors.map(&:name).join('-')}")
      }.join.html_safe
      content_tag(:span, category_text, class: 'category')
    end
  end
end
